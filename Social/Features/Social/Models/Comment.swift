
import Foundation

// MARK: - Comment Models
struct Comment: Codable, Identifiable {
    let id: Int
    let userId: Int
    let postId: Int
    let content: String
    let createdAt: String
    let user: User
}

struct CreateCommentRequest: Codable {
    let content: String
}
