//
//  UserSession.swift
//  Social
//
//  Created by Gourob Mazumder on 29/10/25.
//

import Foundation
import Observation

@Observable
class UserSession{
    var currentUser: User?
    private(set) var isLoggedIn = false
    
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
