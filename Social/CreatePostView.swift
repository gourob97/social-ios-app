//
//  CreatePostView.swift
//  Social
//
//  Created by Gourob Mazumder on 28/10/25.
//

import SwiftUI

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userSession: UserSession
    @State private var content = ""
    @State private var imageUrl = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    let onPostCreated: (Post) -> Void
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Create New Post")
                    .font(.title2)
                    .fontWeight(.bold)
                
                TextEditor(text: $content)
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                TextField("Image URL (optional)", text: $imageUrl)
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
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        createPost()
                    }
                    .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                }
            }
        }
    }
    
    private func createPost() {
        guard let currentUser = userSession.currentUser else { return }
        
        isLoading = true
        errorMessage = ""
        
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedImageUrl = imageUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalImageUrl = trimmedImageUrl.isEmpty ? nil : trimmedImageUrl
        
        Task {
            do {
                let newPost = try await APIService.shared.createPost(
                    content: trimmedContent,
                    imageUrl: finalImageUrl,
                    userId: currentUser.id
                )
                
                await MainActor.run {
                    onPostCreated(newPost)
                    dismiss()
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
    CreatePostView { _ in }
        .environmentObject(UserSession())
}