//
//  Endpoints.swift
//  Social
//
//  Created by Gourob Mazumder on 29/10/25.
//

import Foundation

struct Endpoints {
    static let baseURL = "http://localhost:8081/api"
    
    // MARK: - Authentication Endpoints
    struct Auth {
        static let register = "\(baseURL)/register"
        static let login = "\(baseURL)/login"
        static func profile(id: Int) -> String { "\(baseURL)/profile/\(id)" }
    }
    
    // MARK: - Post Endpoints
    struct Posts {
        static let posts = "\(baseURL)/posts"
        static func post(id: Int) -> String { "\(baseURL)/posts/\(id)" }
        static func like(postId: Int) -> String { "\(baseURL)/posts/\(postId)/like" }
        static func comments(postId: Int) -> String { "\(baseURL)/posts/\(postId)/comments" }
    }
}