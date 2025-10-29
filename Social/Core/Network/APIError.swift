//
//  APIError.swift
//  Social
//
//  Created by Gourob Mazumder on 29/10/25.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case encodingError
    case decodingError
    case networkError
    case invalidResponse
    case serverError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .encodingError:
            return "Failed to encode request"
        case .decodingError:
            return "Failed to decode response"
        case .networkError:
            return "Network error occurred"
        case .invalidResponse:
            return "Invalid response"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        }
    }
}