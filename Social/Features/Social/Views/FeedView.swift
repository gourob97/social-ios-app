//
//  FeedView.swift
//  Social
//
//  Created by Gourob Mazumder on 28/10/25.
//

import SwiftUI

struct FeedView: View {
    @Environment(UserSession.self) var userSession: UserSession
    @State private var feedViewModel = FeedViewModel()
    @State private var showingCreatePost = false
    
    var body: some View {
        NavigationView {
            VStack {
                if feedViewModel.isLoading && feedViewModel.posts.isEmpty {
                    ProgressView("Loading posts...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if feedViewModel.posts.isEmpty && !feedViewModel.errorMessage.isEmpty {
                    VStack {
                        Text("Error loading posts")
                            .font(.headline)
                        Text(feedViewModel.errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                        Button("Retry") {
                            feedViewModel.loadPosts()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if feedViewModel.posts.isEmpty {
                    Text("No posts yet")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(feedViewModel.posts) { post in
                        PostRowView(post: post, feedViewModel: feedViewModel)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        feedViewModel.loadPosts()
                    }
                }
            }
            .navigationTitle("Social Feed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Profile") {
                        // Navigate to profile
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingCreatePost = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreatePost) {
                CreatePostView(onPostCreated: { newPost in
                    feedViewModel.addNewPost(newPost)
                })
            }
        }
    }

}

struct PostRowView: View {
    let post: Post
    let feedViewModel: FeedViewModel
    @Environment(UserSession.self) var userSession: UserSession
    @State private var showingComments = false
    @State private var isLiking = false
   
    
    init(post: Post, feedViewModel: FeedViewModel) {
        self.post = post
        self.feedViewModel = feedViewModel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // User info
            HStack {
                AsyncImage(url: URL(string: post.user.profileImageUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Text(String(post.user.username.prefix(1)).uppercased())
                                .font(.caption)
                                .foregroundColor(.white)
                        )
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                
                VStack(alignment: .leading) {
                    Text(post.user.fullName ?? post.user.username)
                        .font(.headline)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Text(formatDate(post.createdAt))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
            }
            
            // Post content
            Text(post.content)
                .font(.body)
            
            // Post image
            if let imageUrl = post.imageUrl, let url = URL(string: imageUrl) {
                CustomAsyncImage(url: url)
            }
            
            // Action buttons
            HStack(spacing: 30) {
                Button(action: toggleLike) {
                    HStack(spacing: 4) {
                        Image(systemName: post.isLiked ?? false ? "heart.fill" : "heart")
                            .foregroundColor(post.isLiked  ?? false ? .red : .gray)
                        Text("Like")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                }
                .disabled(isLiking)
                .buttonStyle(PlainButtonStyle())
                
                Button(action: { showingComments = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                            .foregroundColor(.gray)
                        Text("Comments")
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
        .sheet(isPresented: $showingComments) {
            CommentsView(postId: post.id)
        }
    }
    
    private func toggleLike() {
        isLiking = true
        
        feedViewModel.toggleLike(for: post, isCurrentlyLiked: post.isLiked ?? false) { newLikeState in
            isLiking = false
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        guard let date = isoFormatter.date(from: dateString) else { return "" }

        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        displayFormatter.doesRelativeDateFormatting = true

        return displayFormatter.string(from: date)
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
    
    let samplePost = Post(
        id: 1,
        userId: 1,
        content: "This is a sample post content that demonstrates how posts will look in the feed.",
        imageUrl: nil,
        createdAt: "2025-10-28T10:30:00",
        user: sampleUser,
        isLiked: false
    )
    
     PostRowView(post: samplePost, feedViewModel: FeedViewModel())
        .environment(UserSession.shared)
        .padding()
}
