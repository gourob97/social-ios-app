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
    func createPost(content: String, imageUrl: String?, userId: Int) async throws -> Post {
        let request = CreatePostRequest(content: content, imageUrl: imageUrl)
        return try await apiClient.performRequest(
            url: Endpoints.Posts.posts,
            method: "POST",
            body: request,
            responseType: Post.self,
            userIdHeader: userId
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
    
    func deletePost(id: Int, userId: Int) async throws -> String {
        return try await apiClient.performRequest(
            url: Endpoints.Posts.post(id: id),
            method: "DELETE",
            responseType: String.self,
            userIdHeader: userId
        )
    }
    
    // MARK: - Like Methods
    func likePost(id: Int, userId: Int) async throws -> String {
        return try await apiClient.performRequest(
            url: Endpoints.Posts.like(postId: id),
            method: "POST",
            responseType: String.self,
            userIdHeader: userId
        )
    }
    
    func unlikePost(id: Int, userId: Int) async throws -> String {
        return try await apiClient.performRequest(
            url: Endpoints.Posts.like(postId: id),
            method: "DELETE",
            responseType: String.self,
            userIdHeader: userId
        )
    }
    
    // MARK: - Comment Methods
    func addComment(postId: Int, content: String, userId: Int) async throws -> Comment {
        let request = CreateCommentRequest(content: content)
        return try await apiClient.performRequest(
            url: Endpoints.Posts.comments(postId: postId),
            method: "POST",
            body: request,
            responseType: Comment.self,
            userIdHeader: userId
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