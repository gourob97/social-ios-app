//
//  FeedRepository.swift
//  Social
//
//  Created by Gourob Mazumder on 5/11/25.
//

import Foundation

protocol FeedRepository {
    func fetchFeed() async throws -> [Post]
}


class FeedRepositoryImpl: FeedRepository {
    
    let feedService: FeedAPIService = FeedAPIServiceImpl()
    
    
    func fetchFeed() async throws -> [Post] {
        let dtos = try await feedService.getFeed()
        return dtos.compactMap { $0.toDomain() }
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
