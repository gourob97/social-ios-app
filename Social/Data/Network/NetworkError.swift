//
//  NetworkError.swift
//  Social
//
//  Created by Gourob Mazumder on 5/11/25.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case serverError(code: Int, message: String)
    case decodingError(Error)
    case urlError(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .serverError(_, let message): return message
        case .decodingError(let error): return "Decoding failed: \(error.localizedDescription)"
        case .urlError(let error): return "Network error: \(error.localizedDescription)"
        case .unknown: return "Unknown error occurred"
        }
    }
}
