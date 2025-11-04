//
//  APIClient.swift
//  Social
//
//  Created by Gourob Mazumder on 29/10/25.
//

import Foundation
import Alamofire

struct EmptyBody: Codable {}

// MARK: - Error Response Model
struct ErrorResponse: Codable {
    let message: String
    let details: String?
}

class APIClient {
    static let shared = APIClient()
    private let baseURL = "http://localhost:8081/api"
    private let session: Session
    private let logger = NetworkLogger.shared
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = Session(configuration: configuration)
    }
    
    // MARK: - Generic Request Handler
    func performRequest<U: Codable>(
        url: String,
        method: String,
        responseType: U.Type,
        authToken: String? = nil
    ) async throws -> U {
        return try await performRequestWithBody(
            url: url,
            method: method,
            body: Optional<EmptyBody>.none,
            responseType: responseType,
            authToken: authToken
        )
    }
    
    func performRequest<T: Codable, U: Codable>(
        url: String,
        method: String,
        body: T,
        responseType: U.Type,
        authToken: String? = nil
    ) async throws -> U {
        return try await performRequestWithBody(
            url: url,
            method: method,
            body: body,
            responseType: responseType,
            authToken: authToken
        )
    }
    
    private func performRequestWithBody<T: Codable, U: Codable>(
        url: String,
        method: String,
        body: T?,
        responseType: U.Type,
        authToken: String? = nil
    ) async throws -> U {
        // Convert string method to Alamofire HTTPMethod
        let httpMethod = HTTPMethod(rawValue: method)
        
        // Prepare headers
        var headers = HTTPHeaders()
        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        
        if let token = authToken {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            // Log the request details
            logger.logRequest(url: url, method: httpMethod, headers: headers, body: body)
            
            let dataRequest: DataRequest
            
            if let body = body {
                // Use Alamofire's built-in JSON encoding
                dataRequest = session.request(
                    url,
                    method: httpMethod,
                    parameters: body,
                    encoder: JSONParameterEncoder.default,
                    headers: headers
                )
            } else {
                dataRequest = session.request(
                    url,
                    method: httpMethod,
                    headers: headers
                )
            }
            
            // Log the actual Alamofire request (shows real curl command)
            logger.logAlamofireRequest(dataRequest)
            
            dataRequest.response { response in
                // Log the response
                self.logger.logResponse(
                    url: url,
                    statusCode: response.response?.statusCode,
                    headers: response.response?.allHeaderFields,
                    data: response.data,
                    error: response.error
                )
                
                switch response.result {
                case .success(let data):
                    guard let httpResponse = response.response else {
                        continuation.resume(throwing: APIError.invalidResponse)
                        return
                    }
                    
                    if 200...299 ~= httpResponse.statusCode {
                        // Success - decode the expected response
                        do {
                            let decodedResponse = try JSONDecoder().decode(responseType, from: data ?? Data())
                            continuation.resume(returning: decodedResponse)
                        } catch {
                            print("Decoding error: \(error)")
                            continuation.resume(throwing: APIError.decodingError)
                        }
                    } else {
                        // Error status code - try to parse structured error response
                        if let data = data, !data.isEmpty {
                            do {
                                let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                                continuation.resume(throwing: APIError.serverErrorResponse(errorResponse))
                            } catch {
                                print("Failed to parse error response: \(error)")
                                continuation.resume(throwing: APIError.serverError(httpResponse.statusCode))
                            }
                        } else {
                            continuation.resume(throwing: APIError.serverError(httpResponse.statusCode))
                        }
                    }
                    
                case .failure(let error):
                    let apiError = self.mapAlamofireError(error)
                    continuation.resume(throwing: apiError)
                }
            }
        }
    }
    
    private func mapAlamofireError(_ error: AFError) -> APIError {
        switch error {
        case .invalidURL:
            return .invalidURL
            
        case .parameterEncodingFailed:
            return .encodingError
            
        case .responseValidationFailed(reason: .unacceptableStatusCode(let code)):
            return .serverError(code)
            
        case .responseSerializationFailed(reason: .decodingFailed):
            return .decodingError
            
        case .sessionTaskFailed(let urlError as URLError):
            if urlError.code == .notConnectedToInternet {
                return .networkError
            }
            return .networkError
            
        default:
            return .networkError
        }
    }
    
    var baseAPIURL: String {
        return baseURL
    }
}


final class ConsoleNetworkLogger: EventMonitor {
    let queue = DispatchQueue(label: "networklogger")

    // Called when a request starts
    func requestDidResume(_ request: Request) {
        print("➡️ Request: \(request.description)")
        if let body = request.request?.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            print("Body:\n\(bodyString)")
        }
    }

    // Called when response finishes
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        if let data = response.data {
            if let json = try? JSONSerialization.jsonObject(with: data),
               let pretty = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted]),
               let prettyString = String(data: pretty, encoding: .utf8) {
                print("⬅️ Response JSON:\n\(prettyString)")
            } else if let text = String(data: data, encoding: .utf8) {
                print("⬅️ Response Text:\n\(text)")
            }
        }
        if let error = response.error {
            print("❌ Error: \(error.localizedDescription)")
        }
    }
}
