//
//  AuthViewModel.swift
//  Social
//
//  Created by Gourob Mazumder on 29/10/25.
//

import Foundation


@Observable
class AuthViewModel{
    var isLoading = false
    var errorMessage = ""
    
    private let authService = AuthService.shared
    
    func login(email: String?, username: String?, password: String, userSession: UserSession) async {
        isLoading = true
        errorMessage = ""
        
        do {
            let loginResponse = try await authService.login(
                email: email,
                username: username,
                password: password
            )
            
            let user = try await authService.getUserProfile(id: loginResponse.id)
            userSession.login(user: user)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
    
    func register(username: String, email: String, password: String, userSession: UserSession) async {
        isLoading = true
        errorMessage = ""
        
        do {
            let user = try await authService.register(
                username: username,
                email: email,
                password: password
            )
            
            userSession.login(user: user)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }
}
