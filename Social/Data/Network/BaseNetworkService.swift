//
//  BaseNetworkService.swift
//  Social
//
//  Created by Gourob Mazumder on 5/11/25.
//

import Foundation
import Alamofire

class BaseNetworkService {
    
    func executeRequest<T: Decodable>(_ request: DataRequest) async throws -> T {
        do {
            let response = await request
                .validate()
                .serializingDecodable(T.self)
                .response
            
            
            switch response.result {
            case .success(let value):
                return value
            case .failure(let afError):
                throw parseAFError(afError, response.data)
            }
        } catch {
            throw parseError(error)
        }
    }
    
    func executeRequest(_ request: DataRequest) async throws {
        do {
            _ = try await request
                .validate()
                .serializingData()
                .value
        } catch {
            throw parseError(error)
        }
    }
    
    
    private func parseAFError(_ error: AFError, _ data: Data?) -> NetworkError {
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let message = json["message"] as? String,
               let code = json["code"] as? Int {
                return .serverError(code: code, message: message)
            }
            return .urlError(error)
        }

        private func parseError(_ error: Error) -> NetworkError {
            if let afError = error as? AFError {
                return .urlError(afError)
            } else if let decodingError = error as? DecodingError {
                return .decodingError(decodingError)
            } else {
                return .unknown
            }
        }
}
