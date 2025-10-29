//
//  User.swift
//  Social
//
//  Created by Gourob Mazumder on 29/10/25.
//

import Foundation

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
