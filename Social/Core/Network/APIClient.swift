//
//  APIClient.swift
//  Social
//
//  Created by Gourob Mazumder on 29/10/25.
//

import Foundation

struct EmptyBody: Codable {}

class APIClient {
    static let shared = APIClient()
    private let baseURL = "http://localhost:8081/api"
    
    private init() {}
    
    // MARK: - Generic Request Handler
    func performRequest<U: Codable>(
        url: String,
        method: String,
        responseType: U.Type,
        userIdHeader: Int? = nil
    ) async throws -> U {
        return try await performRequestWithBody(
            url: url,
            method: method,
            body: Optional<EmptyBody>.none,
            responseType: responseType,
            userIdHeader: userIdHeader
        )
    }
    
    func performRequest<T: Codable, U: Codable>(
        url: String,
        method: String,
        body: T,
        responseType: U.Type,
        userIdHeader: Int? = nil
    ) async throws -> U {
        return try await performRequestWithBody(
            url: url,
            method: method,
            body: body,
            responseType: responseType,
            userIdHeader: userIdHeader
        )
    }
    
    private func performRequestWithBody<T: Codable, U: Codable>(
        url: String,
        method: String,
        body: T?,
        responseType: U.Type,
        userIdHeader: Int? = nil
    ) async throws -> U {
        guard let requestURL = URL(string: url) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let userId = userIdHeader {
            request.setValue("\(userId)", forHTTPHeaderField: "User-ID")
        }
        
        if let body = body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw APIError.encodingError
            }
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard 200...299 ~= httpResponse.statusCode else {
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            do {
                let result = try JSONDecoder().decode(responseType, from: data)
                return result
            } catch {
                print("Decoding error: \(error)")
                throw APIError.decodingError
            }
        } catch {
            if error is APIError {
                throw error
            } else {
                throw APIError.networkError
            }
        }
    }
    
    var baseAPIURL: String {
        return baseURL
    }
}