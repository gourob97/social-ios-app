//
//  CommentsView.swift
//  Social
//
//  Created by Gourob Mazumder on 28/10/25.
//

import SwiftUI

struct CommentsView: View {
    let postId: Int
    @Environment(\.dismiss) private var dismiss
    @Environment(UserSession.self)var userSession: UserSession
    @State private var comments: [Comment] = []
    @State private var newCommentText = ""
    @State private var isLoading = false
    @State private var isAddingComment = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading && comments.isEmpty {
                    ProgressView("Loading comments...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if comments.isEmpty {
                    Text("No comments yet")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(comments) { comment in
                        CommentRowView(comment: comment)
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(PlainListStyle())
                }
                
                Divider()
                
                // Add comment section
                HStack {
                    TextField("Add a comment...", text: $newCommentText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Post") {
                        addComment()
                    }
                    .disabled(newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isAddingComment)
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            loadComments()
        }
    }
    
    private func loadComments() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let fetchedComments = try await SocialService.shared.getComments(postId: postId)
                await MainActor.run {
                    self.comments = fetchedComments
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    private func addComment() {
        guard let currentUser = userSession.currentUser else { return }
        
        isAddingComment = true
        let commentText = newCommentText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Task {
            do {
                let newComment = try await SocialService.shared.addComment(
                    postId: postId,
                    content: commentText,
                    userId: currentUser.id
                )
                
                await MainActor.run {
                    comments.append(newComment)
                    newCommentText = ""
                    isAddingComment = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isAddingComment = false
                }
            }
        }
    }
}

struct CommentRowView: View {
    let comment: Comment
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: URL(string: comment.user.profileImageUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Text(String(comment.user.username.prefix(1)).uppercased())
                            .font(.caption)
                            .foregroundColor(.white)
                    )
            }
            .frame(width: 30, height: 30)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(comment.user.fullName ?? comment.user.username)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("@\(comment.user.username)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text(formatDate(comment.createdAt))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(comment.content)
                    .font(.body)
            }
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .short
            displayFormatter.timeStyle = .short
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

#Preview {
    let sampleUser = User(
        id: 1,
        username: "john_doe",
        email: "john@example.com",
        role: "user",
        isActive: true,
        fullName: "John Doe",
        bio: "Software Developer",
        profileImageUrl: nil
    )
    
    return CommentsView(postId: 1)
        .environment(UserSession())
}
