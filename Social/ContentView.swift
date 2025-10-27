//
//  ContentView.swift
//  Social
//
//  Created by Gourob Mazumder on 28/10/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var userSession = UserSession()
    
    var body: some View {
        Group {
            if userSession.isLoggedIn {
                MainTabView()
            } else {
                AuthView()
            }
        }
        .environmentObject(userSession)
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
