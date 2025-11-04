//
//  AuthViews.swift
//  Social
//
//  Created by Gourob Mazumder on 28/10/25.
//

import SwiftUI

struct AuthView: View {
    @State private var isLoginMode = true
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Mode", selection: $isLoginMode) {
                    Text("Login").tag(true)
                    Text("Register").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if isLoginMode {
                    LoginView()
                } else {
                    RegisterView()
                }
                
                Spacer()
            }
            .navigationTitle(isLoginMode ? "Login" : "Register")
        }
    }
}

struct LoginView: View {
    @Environment(UserSession.self) var userSession: UserSession
    @State private var authviewmodel = AuthViewModel()
    @State private var emailOrUsername = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("Email or Username", text: $emailOrUsername)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: login) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text("Login")
                }
            }
            .disabled(isLoading || emailOrUsername.isEmpty || password.isEmpty)
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    func login() {
        Task {
            await authviewmodel.login(email: emailOrUsername, username: emailOrUsername, password: password)
        }
    }
    
}

struct RegisterView: View {
    @Environment(UserSession.self) var userSession: UserSession
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: register) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text("Register")
                }
            }
            .disabled(isLoading || username.isEmpty || email.isEmpty || password.isEmpty)
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private func register() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let user = try await AuthService.shared.register(
                    username: username,
                    email: email,
                    password: password
                )
                
                await MainActor.run {
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
}

#Preview {
    AuthView()
        .environment(UserSession.shared)
}
