//
//  FeedViewModel.swift
//  Social
//
//  Created by Gourob Mazumder on 05/11/25.
//

import Foundation

@Observable
class FeedViewModel {
    var posts: [PostUiModel] = []
    var isLoading = false
    var errorMessage = ""
    
    private let socialService = SocialService.shared
    private let userSession = UserSession.shared
    
    private let feedRepository = FeedRepositoryImpl()
    
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
                self.posts =  try await feedRepository.fetchFeed().map { post in
                    post.toUiModel()
                }
                self.isLoading = false
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    func addNewPost(_ post: PostUiModel) {
        posts.insert(post, at: 0)
    }
    
    func toggleLike(for post: PostUiModel, isCurrentlyLiked: Bool, completion: @escaping (Bool) -> Void) {
        guard userSession.currentUser != nil else {
            print("User not logged in")
            completion(isCurrentlyLiked) // Return original state
            return
        }
        
        Task {
            do {
                if isCurrentlyLiked {
                    _ = try await feedRepository.unlikePost(id: post.id, userSession: userSession)
                } else {
                    _ = try await feedRepository.likePost(id: post.id, userSession: userSession)
                }
                
                await MainActor.run {
                    completion(!isCurrentlyLiked) // Return toggled state
                    if let index = posts.firstIndex(where: { $0.id == post.id }) {
                        posts[index].isLiked.toggle()
                    }
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
