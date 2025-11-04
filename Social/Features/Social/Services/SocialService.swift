//
//  SocialService.swift
//  Social
//
//  Created by Gourob Mazumder on 29/10/25.
//

import Foundation

class SocialService {
    static let shared = SocialService()
    private let apiClient = APIClient.shared
    
    private init() {}
    
    // MARK: - Post Methods
    func createPost(content: String, imageUrl: String?, userSession: UserSession) async throws -> Post {
        guard let userId = userSession.currentUserId else {
            throw APIError.unauthorized
        }
        
        let request = CreatePostRequest(content: content, imageUrl: imageUrl)
        return try await apiClient.performRequest(
            url: Endpoints.Posts.posts,
            method: "POST",
            body: request,
            responseType: Post.self,
            authToken: userSession.authToken
        )
    }
    
    func getAllPosts() async throws -> [Post] {
        return try await apiClient.performRequest(
            url: Endpoints.Posts.posts,
            method: "GET",
            responseType: [Post].self
        )
    }
    
    func getPost(id: Int) async throws -> Post {
        return try await apiClient.performRequest(
            url: Endpoints.Posts.post(id: id),
            method: "GET",
            responseType: Post.self
        )
    }
    
    func deletePost(id: Int, userSession: UserSession) async throws -> String {
        guard let userId = userSession.currentUserId else {
            throw APIError.unauthorized
        }
        
        return try await apiClient.performRequest(
            url: Endpoints.Posts.post(id: id),
            method: "DELETE",
            responseType: String.self,
            authToken: userSession.authToken
        )
    }
    
    // MARK: - Like Methods
    func likePost(id: Int, userSession: UserSession) async throws -> String {
        guard let userId = userSession.currentUserId else {
            throw APIError.unauthorized
        }
        
        return try await apiClient.performRequest(
            url: Endpoints.Posts.like(postId: id),
            method: "POST",
            responseType: String.self,
            authToken: userSession.authToken
        )
    }
    
    func unlikePost(id: Int, userSession: UserSession) async throws -> String {
        guard let userId = userSession.currentUserId else {
            throw APIError.unauthorized
        }
        
        return try await apiClient.performRequest(
            url: Endpoints.Posts.like(postId: id),
            method: "DELETE",
            responseType: String.self,
            authToken: userSession.authToken
        )
    }
    
    // MARK: - Comment Methods
    func addComment(postId: Int, content: String, userSession: UserSession) async throws -> Comment {
        guard let userId = userSession.currentUserId else {
            throw APIError.unauthorized
        }
        
        let request = CreateCommentRequest(content: content)
        return try await apiClient.performRequest(
            url: Endpoints.Posts.comments(postId: postId),
            method: "POST",
            body: request,
            responseType: Comment.self,
            authToken: userSession.authToken
        )
    }
    
    func getComments(postId: Int) async throws -> [Comment] {
        return try await apiClient.performRequest(
            url: Endpoints.Posts.comments(postId: postId),
            method: "GET",
            responseType: [Comment].self
        )
    }
}
