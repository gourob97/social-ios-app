//
//  AuthViewModel.swift
//  Social
//
//  Created by Gourob Mazumder on 29/10/25.
//

import Foundation


@Observable
class AuthViewModel {
    var isLoading = false
    var errorMessage = ""
    var registrationSuccessful = false
    var successMessage = ""
    var isLoggedIn = false
    
    private let authService = AuthService.shared
    private let userSession = UserSession.shared
    
    init() {
        // Initialize with current UserSession state
        self.isLoggedIn = userSession.isLoggedIn
        
        // Load stored session data if available
        if userSession.hasStoredSession {
            Task {
                await loadStoredUserSession()
            }
        }
    }
    
    // Load stored user session on app launch
    private func loadStoredUserSession() async {
        guard let storedUserId = userSession.storedUserId,
              let authToken = userSession.authToken else {
            return
        }
        
        do {
            let user = try await authService.getUserProfile(id: storedUserId)
            await MainActor.run {
                userSession.login(user: user, token: authToken)
                self.isLoggedIn = true
            }
        } catch {
            print("Failed to load stored user session: \(error)")
            await MainActor.run {
                userSession.logout()
                self.isLoggedIn = false
            }
        }
    }
   
    
    func login(email: String?, username: String?, password: String) async {
        isLoading = true
        errorMessage = ""
        registrationSuccessful = false
        successMessage = ""
        
        do {
            let loginResponse = try await authService.login(
                email: email,
                username: username,
                password: password
            )
            
            let user = try await authService.getUserProfile(id: loginResponse.id)
            
            await MainActor.run {
                // Store auth token and user data through ViewModel
                userSession.login(user: user, token: loginResponse.token)
                self.isLoggedIn = true
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
    
    func register(username: String, email: String, password: String) async {
        isLoading = true
        errorMessage = ""
        registrationSuccessful = false
        successMessage = ""
        
        do {
            _ = try await authService.register(
                username: username,
                email: email,
                password: password
            )
            
            // Registration successful - user must now log in manually
            registrationSuccessful = true
            successMessage = "Account created successfully! Please log in with your credentials."
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            registrationSuccessful = false
            isLoading = false
        }
    }
    
    func logout() async {
        isLoading = true
        
        do {
            // Optional: Call logout API if your server has one
            // try await authService.logout(authToken: userSession.authToken)
            
            await MainActor.run {
                // Clear UserSession through ViewModel
                userSession.logout()
                self.isLoggedIn = false
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}
