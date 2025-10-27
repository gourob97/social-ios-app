//
//  Models.swift
//  Social
//
//  Created by Gourob Mazumder on 28/10/25.
//

import Foundation
internal import Combine

// MARK: - User Models
struct User: Codable, Identifiable {
    let id: Int
    let username: String
    let email: String
    let role: String
    let isActive: Bool
    let fullName: String?
    let bio: String?
    let profileImageUrl: String?
}

struct RegisterRequest: Codable {
    let username: String
    let email: String
    let password: String
}

struct LoginRequest: Codable {
    let email: String?
    let username: String?
    let password: String
}

struct LoginResponse: Codable {
    let id: Int
    let email: String
    let username: String
    let token: String
}

struct UpdateProfileRequest: Codable {
    let fullName: String?
    let bio: String?
    let profileImageUrl: String?
}

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

// MARK: - Comment Models
struct Comment: Codable, Identifiable {
    let id: Int
    let userId: Int
    let postId: Int
    let content: String
    let createdAt: String
    let user: User
}

struct CreateCommentRequest: Codable {
    let content: String
}

// MARK: - Current User State
class UserSession: ObservableObject {
    @Published var currentUser: User?
    @Published private(set) var isLoggedIn = false
    
    init() {
        // Check if user was previously logged in
        if let userId = UserDefaults.standard.object(forKey: "userId") as? Int {
            self.loadCurrentUser(userId: userId)
        }
    }
    
    func login(user: User) {
        self.currentUser = user
        self.isLoggedIn = true
        UserDefaults.standard.set(user.id, forKey: "userId")
    }
    
    func logout() {
        self.currentUser = nil
        self.isLoggedIn = false
        UserDefaults.standard.removeObject(forKey: "userId")
    }
    
    private func loadCurrentUser(userId: Int) {
        // In a real app, you would fetch the user from the API
        // For now, we'll just set the logged in state
        self.isLoggedIn = true
    }
}
