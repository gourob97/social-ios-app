//
//  Post.swift
//  Social
//
//  Created by Gourob Mazumder on 5/11/25.
//

import Foundation


struct PostUiModel: Identifiable {
    let id: Int
    let content: String
    let userName: String
    let imageUrl: String?
    let createdAt: String
    var isLiked: Bool
    let displayName: String
}


extension Post {
    func toUiModel() -> PostUiModel {
        return PostUiModel(
            id: self.id,
            content: self.content,
            userName: self.user.username,
            imageUrl: self.imageUrl,
            createdAt: DateTimeUtility.formatDate(self.createdAt),
            isLiked: self.isLiked,
            displayName: self.user.fullName ?? self.user.username
        )
    }
}
