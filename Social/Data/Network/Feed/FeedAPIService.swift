//
//  FeedAPIService.swift
//  Social
//
//  Created by Gourob Mazumder on 5/11/25.
//

import Foundation

protocol FeedAPIService {
    func getFeed() async throws -> [PostDTO]
    func likePost(id: Int, userSession: UserSession) async throws -> Void
    func unlikePost(id: Int, userSession: UserSession) async throws -> Void
}


