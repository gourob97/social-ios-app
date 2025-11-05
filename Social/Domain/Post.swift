//
//  Post.swift
//  Social
//
//  Created by Gourob Mazumder on 5/11/25.
//

import Foundation


struct Post: Codable, Identifiable {
    let id: Int
    let userId: Int
    let content: String
    let imageUrl: String?
    let createdAt: String
    let user: User
    let isLiked: Bool
}

struct CreatePostRequest: Codable {
    let content: String
    let imageUrl: String?
}
