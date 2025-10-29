//
//  Post.swift
//  Social
//
//  Created by Gourob Mazumder on 29/10/25.
//

import Foundation

// MARK: - Post Models
struct Post: Codable, Identifiable {
    let id: Int
    let userId: Int
    let content: String
    let imageUrl: String?
    let createdAt: String
    let user: User
}

struct CreatePostRequest: Codable {
    let content: String
    let imageUrl: String?
}
