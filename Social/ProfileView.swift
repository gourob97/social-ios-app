//
//  ProfileView.swift
//  Social
//
//  Created by Gourob Mazumder on 28/10/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var isEditing = false
    @State private var fullName = ""
    @State private var bio = ""
    @State private var profileImageUrl = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let user = userSession.currentUser {
                        // Profile Image
                        AsyncImage(url: URL(string: user.profileImageUrl ?? "")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Text(String(user.username.prefix(1)).uppercased())
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                )
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        
                        // User Info
                        VStack(spacing: 8) {
                            Text(user.fullName ?? user.username)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("@\(user.username)")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            if let bio = user.bio, !bio.isEmpty {
                                Text(bio)
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            
                            Text(user.email)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        // Action Buttons
                        HStack(spacing: 20) {
                            Button("Edit Profile") {
                                fullName = user.fullName ?? ""
                                bio = user.bio ?? ""
                                profileImageUrl = user.profileImageUrl ?? ""
                                isEditing = true
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("Logout") {
                                userSession.logout()
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $isEditing) {
                EditProfileView(
                    fullName: $fullName,
                    bio: $bio,
                    profileImageUrl: $profileImageUrl,
                    isLoading: $isLoading,
                    errorMessage: $errorMessage,
                    onSave: updateProfile
                )
            }
        }
    }
    
    private func updateProfile() {
        guard let currentUser = userSession.currentUser else { return }
        
        isLoading = true
        errorMessage = ""
        
        let trimmedFullName = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedImageUrl = profileImageUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Task {
            do {
                let updatedUser = try await APIService.shared.updateProfile(
                    id: currentUser.id,
                    fullName: trimmedFullName.isEmpty ? nil : trimmedFullName,
                    bio: trimmedBio.isEmpty ? nil : trimmedBio,
                    profileImageUrl: trimmedImageUrl.isEmpty ? nil : trimmedImageUrl
                )
                
                await MainActor.run {
                    userSession.currentUser = updatedUser
                    isLoading = false
                    isEditing = false
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

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var fullName: String
    @Binding var bio: String
    @Binding var profileImageUrl: String
    @Binding var isLoading: Bool
    @Binding var errorMessage: String
    
    let onSave: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Edit Profile")
                    .font(.title2)
                    .fontWeight(.bold)
                
                TextField("Full Name", text: $fullName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Bio", text: $bio, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
                
                TextField("Profile Image URL", text: $profileImageUrl)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isLoading)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                    }
                    .disabled(isLoading)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserSession())
}