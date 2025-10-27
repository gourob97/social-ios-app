//
//  APIService.swift
//  Social
//
//  Created by Gourob Mazumder on 28/10/25.
//

import Foundation

struct EmptyBody: Codable {}

class APIService {

    
    static let shared = APIService()
    private let baseURL = "http://localhost:8081/api"
    
    private init() {}
    
    // MARK: - User Endpoints
    func register(username: String, email: String, password: String) async throws -> User {
        let request = RegisterRequest(username: username, email: email, password: password)
        return try await performRequest(
            url: "\(baseURL)/register",
            method: "POST",
            body: request,
            responseType: User.self
        )
    }
    
    func login(email: String?, username: String?, password: String) async throws -> LoginResponse {
        let request = LoginRequest(email: email, username: username, password: password)
        return try await performRequest(
            url: "\(baseURL)/login",
            method: "POST",
            body: request,
            responseType: LoginResponse.self
        )
    }
    
    func getUserProfile(id: Int) async throws -> User {
        return try await performRequest(
            url: "\(baseURL)/profile/\(id)",
            method: "GET",
            responseType: User.self
        )
    }
    
    func updateProfile(id: Int, fullName: String?, bio: String?, profileImageUrl: String?) async throws -> User {
        let request = UpdateProfileRequest(fullName: fullName, bio: bio, profileImageUrl: profileImageUrl)
        return try await performRequest(
            url: "\(baseURL)/profile/\(id)",
            method: "PUT",
            body: request,
            responseType: User.self
        )
    }
    
    // MARK: - Post Endpoints
    func createPost(content: String, imageUrl: String?, userId: Int) async throws -> Post {
        let request = CreatePostRequest(content: content, imageUrl: imageUrl)
        return try await performRequest(
            url: "\(baseURL)/posts",
            method: "POST",
            body: request,
            responseType: Post.self,
            userIdHeader: userId
        )
    }
    
    func getAllPosts() async throws -> [Post] {
        return try await performRequest(
            url: "\(baseURL)/posts",
            method: "GET",
            responseType: [Post].self
        )
    }
    
    func getPost(id: Int) async throws -> Post {
        return try await performRequest(
            url: "\(baseURL)/posts/\(id)",
            method: "GET",
            responseType: Post.self
        )
    }
    
    func deletePost(id: Int, userId: Int) async throws -> String {
        return try await performRequest(
            url: "\(baseURL)/posts/\(id)",
            method: "DELETE",
            responseType: String.self,
            userIdHeader: userId
        )
    }
    
    // MARK: - Like Endpoints
    func likePost(id: Int, userId: Int) async throws -> String {
        return try await performRequest(
            url: "\(baseURL)/posts/\(id)/like",
            method: "POST",
            responseType: String.self,
            userIdHeader: userId
        )
    }
    
    func unlikePost(id: Int, userId: Int) async throws -> String {
        return try await performRequest(
            url: "\(baseURL)/posts/\(id)/like",
            method: "DELETE",
            responseType: String.self,
            userIdHeader: userId
        )
    }
    
    // MARK: - Comment Endpoints
    func addComment(postId: Int, content: String, userId: Int) async throws -> Comment {
        let request = CreateCommentRequest(content: content)
        return try await performRequest(
            url: "\(baseURL)/posts/\(postId)/comments",
            method: "POST",
            body: request,
            responseType: Comment.self,
            userIdHeader: userId
        )
    }
    
    func getComments(postId: Int) async throws -> [Comment] {
        return try await performRequest(
            url: "\(baseURL)/posts/\(postId)/comments",
            method: "GET",
            responseType: [Comment].self
        )
    }
    
    // MARK: - Generic Request Handler
    private func performRequest<U: Codable>(
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
    
    private func performRequest<T: Codable, U: Codable>(
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
            
            if responseType == String.self {
                guard let stringResponse = String(data: data, encoding: .utf8) as? U else {
                    throw APIError.decodingError
                }
                return stringResponse
            } else {
                do {
                    return try JSONDecoder().decode(responseType, from: data)
                } catch {
                    throw APIError.decodingError
                }
            }
        } catch {
            if error is APIError {
                throw error
            } else {
                throw APIError.networkError
            }
        }
    }
}

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
            return "Network error"
        case .invalidResponse:
            return "Invalid response"
        case .serverError(let code):
            return "Server error: \(code)"
        }
    }
}
