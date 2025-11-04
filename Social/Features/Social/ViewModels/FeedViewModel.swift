//
//  FeedViewModel.swift
//  Social
//
//  Created by Gourob Mazumder on 05/11/25.
//

import Foundation

@Observable
class FeedViewModel {
    var posts: [Post] = []
    var isLoading = false
    var errorMessage = ""
    
    private let socialService = SocialService.shared
    private let userSession = UserSession.shared
    
    init() {
        loadPosts()
    }
    
    // MARK: - Public Methods
    
    func loadPosts() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let fetchedPosts = try await socialService.getAllPosts()
                await MainActor.run {
                    self.posts = fetchedPosts
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
    
    func addNewPost(_ post: Post) {
        posts.insert(post, at: 0)
    }
    
    func toggleLike(for post: Post, isCurrentlyLiked: Bool, completion: @escaping (Bool) -> Void) {
        guard userSession.currentUser != nil else {
            print("User not logged in")
            completion(isCurrentlyLiked) // Return original state
            return
        }
        
        Task {
            do {
                if isCurrentlyLiked {
                    _ = try await socialService.unlikePost(id: post.id, userSession: userSession)
                } else {
                    _ = try await socialService.likePost(id: post.id, userSession: userSession)
                }
                
                await MainActor.run {
                    completion(!isCurrentlyLiked) // Return toggled state
                }
            } catch {
                await MainActor.run {
                    print("Error toggling like: \(error)")
                    completion(isCurrentlyLiked) // Return original state on error
                }
            }
        }
    }
}