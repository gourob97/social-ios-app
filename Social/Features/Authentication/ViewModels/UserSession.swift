//
//  UserSession.swift
//  Social
//
//  Created by Gourob Mazumder on 29/10/25.
//

import Foundation
import Observation

@Observable
class UserSession {
    static let shared = UserSession()
    
    var currentUser: User?
    private(set) var isLoggedIn = false
    var authToken: String?
    
    // UserDefaults keys
    private let authTokenKey = "authToken"
    private let userIdKey = "userId"
    
    private init() {
        loadStoredSession()
    }
    
    private func loadStoredSession() {
        print("Loading stored session from UserDefaults")
        if let token = UserDefaults.standard.string(forKey: authTokenKey),
           let userId = UserDefaults.standard.object(forKey: userIdKey) as? Int {
            self.authToken = token
            print("Found stored auth token and userId: \(userId)")
            // Note: User data will be loaded by AuthViewModel on app launch
        } else {
            print("No stored session found")
        }
    }
    
    func login(user: User, token: String) {
        self.currentUser = user
        self.isLoggedIn = true
        self.authToken = token
        
        // Persist user session
        UserDefaults.standard.set(user.id, forKey: userIdKey)
        UserDefaults.standard.set(token, forKey: authTokenKey)
        
        print("User session stored - ID: \(user.id), Token: \(token)")
    }
    
    func logout() {
        self.currentUser = nil
        self.isLoggedIn = false
        self.authToken = nil
        
        // Clear persisted data
        UserDefaults.standard.removeObject(forKey: authTokenKey)
        UserDefaults.standard.removeObject(forKey: userIdKey)
        
        print("User session cleared")
    }
    
    func updateCurrentUser(_ user: User) {
        self.currentUser = user
    }
    
    // Helper method to get current user ID for API calls
    var currentUserId: Int? {
        return currentUser?.id
    }
    
    // Check if user session is valid
    var isSessionValid: Bool {
        return isLoggedIn && currentUser != nil
    }
    
    // Check if we have stored session data (for app launch)
    var hasStoredSession: Bool {
        return authToken != nil && UserDefaults.standard.object(forKey: userIdKey) != nil
    }
    
    // Get stored user ID (for ViewModel to load user data)
    var storedUserId: Int? {
        return UserDefaults.standard.object(forKey: userIdKey) as? Int
    }
}
