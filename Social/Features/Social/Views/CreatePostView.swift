//
//  CreatePostView.swift
//  Social
//
//  Created by Gourob Mazumder on 28/10/25.
//

import SwiftUI


@Observable
class CreatePostViewModel {
    
    var feedRepository: FeedRepository
    var isLoading = false
    var errorMessage = ""
    
    init(feedRepository: FeedRepository = FeedRepositoryImpl()) {
        self.feedRepository = feedRepository
    }
    
    func createPost(content: String, imageUrl: String?, userSession: UserSession) async {
        do {
            _ = try await feedRepository.createPost(content: content, imageUrl: imageUrl, userSession: userSession)
        }
        catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(UserSession.self) var userSession: UserSession
    @State private var content = ""
    @State private var imageUrl = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    @State var createPostViewModel = CreatePostViewModel()
    
    
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
        
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedImageUrl = imageUrl.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalImageUrl = trimmedImageUrl.isEmpty ? nil : trimmedImageUrl
        Task {
            await createPostViewModel.createPost(content: trimmedContent, imageUrl: finalImageUrl, userSession: userSession)
        }
    }
}

#Preview {
    CreatePostView ()
        .environment(UserSession.shared)
}
