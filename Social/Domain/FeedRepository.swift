//
//  FeedRepository.swift
//  Social
//
//  Created by Gourob Mazumder on 5/11/25.
//

import Foundation

protocol FeedRepository {
    func fetchFeed() async throws -> [Post]
    func likePost(id: Int, userSession: UserSession) async throws
    func unlikePost(id: Int, userSession: UserSession) async throws
    func createPost(content: String, imageUrl: String?, userSession: UserSession) async throws -> Post
}


class FeedRepositoryImpl: FeedRepository {
    
    let feedService: FeedAPIService = FeedAPIServiceImpl()
    
    func fetchFeed() async throws -> [Post] {
        let dtos = try await feedService.getFeed()
        return dtos.compactMap { $0.toDomain() }
    }
    
    func likePost(id: Int, userSession: UserSession) async throws {
        try await feedService.likePost(id: id, userSession: userSession)
    }
    
    func unlikePost(id: Int, userSession: UserSession) async throws {
        try await feedService.unlikePost(id: id, userSession: userSession)
    }
        
    func createPost(content: String, imageUrl: String?, userSession: UserSession) async throws -> Post {
        let dto = try await feedService.createPost(content: content, imageUrl: imageUrl, userSession: userSession)
        if let post = dto.toDomain() {
            return post
        } else {
            throw NetworkError.unknown
        }
    }

}


extension PostDTO {
    
    func toDomain() -> Post? {
        guard let id, let userId else {
            return nil
        }
        return Post(
            id: id,
            userId: userId,
            content: content ?? "",
            imageUrl: imageUrl,
            createdAt: createdAt ?? "",
            user: user,
            isLiked: isLiked ?? false,
        )
    }
}
