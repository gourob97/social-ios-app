//
//  AuthService.swift
//  Social
//
//  Created by Gourob Mazumder on 29/10/25.
//

import Foundation

class AuthService {
    static let shared = AuthService()
    private let apiClient = APIClient.shared
    
    private init() {}
    
    // MARK: - Authentication Methods
    func register(username: String, email: String, password: String) async throws -> User {
        let request = RegisterRequest(username: username, email: email, password: password)
        return try await apiClient.performRequest(
            url: Endpoints.Auth.register,
            method: "POST",
            body: request,
            responseType: User.self
        )
    }
    
    func login(email: String?, username: String?, password: String) async throws -> LoginResponse {
        let request = LoginRequest(email: email, username: username, password: password)
        return try await apiClient.performRequest(
            url: Endpoints.Auth.login,
            method: "POST",
            body: request,
            responseType: LoginResponse.self
        )
    }
    
    func getUserProfile(id: Int) async throws -> User {
        return try await apiClient.performRequest(
            url: Endpoints.Auth.profile(id: id),
            method: "GET",
            responseType: User.self
        )
    }
    
    func updateProfile(id: Int, fullName: String?, bio: String?, profileImageUrl: String?) async throws -> User {
        let request = UpdateProfileRequest(fullName: fullName, bio: bio, profileImageUrl: profileImageUrl)
        return try await apiClient.performRequest(
            url: Endpoints.Auth.profile(id: id),
            method: "PUT",
            body: request,
            responseType: User.self
        )
    }
}
