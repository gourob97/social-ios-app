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
    case serverErrorResponse(ErrorResponse)
    case unauthorized
    
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
        case .serverErrorResponse(let errorResponse):
            return errorResponse.message
        case .unauthorized:
            return "User not authenticated"
        }
    }
    
    // MARK: - Helper Methods
    
    /// Returns the server error response if available
    var serverErrorResponse: ErrorResponse? {
        switch self {
        case .serverErrorResponse(let errorResponse):
            return errorResponse
        default:
            return nil
        }
    }
    
    /// Returns the error details from server response if available
    var errorDetails: String? {
        return serverErrorResponse?.details
    }
    
    /// Checks if this is a server error response (has structured error data)
    var isServerErrorResponse: Bool {
        return serverErrorResponse != nil
    }
}
