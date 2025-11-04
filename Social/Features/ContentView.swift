//
//  ContentView.swift
//  Social
//
//  Created by Gourob Mazumder on 28/10/25.
//

import SwiftUI

struct ContentView: View {
    @State private var authViewModel = AuthViewModel()
    private let userSession = UserSession.shared
    
    var body: some View {
        Group {
            if authViewModel.isLoading && !authViewModel.isLoggedIn {
                // Show loading screen while checking for stored auth token
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading...")
                        .font(.headline)
                        .padding(.top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            } else if authViewModel.isLoggedIn {
                MainTabView()
            } else {
                AuthView()
            }
        }
        .environment(userSession)
        .environment(authViewModel)
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Feed")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person")
                    Text("Profile")
                }
        }
    }
}

#Preview {
    ContentView()
}
