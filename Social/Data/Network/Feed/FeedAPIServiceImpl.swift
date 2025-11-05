//
//  FeedAPIServiceImpl.swift
//  Social
//
//  Created by Gourob Mazumder on 5/11/25.
//

import Foundation
import Alamofire


class FeedAPIServiceImpl: FeedAPIService {
    let networkService = BaseNetworkService()
    
    func getFeed() async throws -> [PostDTO] {
        do {
            return try  await networkService.executeRequest(
                AF.request("http://localhost:8081/api/posts", method: .get)
            )
        } catch {
            throw error
        }
    }
    
    func likePost(id: Int, userSession: UserSession) async throws -> Void {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(String(describing: userSession.authToken))",
            "Content-Type": "application/json"
        ]
        do {
            return try await networkService.executeRequest(
                AF.request(
                    Endpoints.Posts.like(postId: id),
                    method: .post,
                    headers: headers
                )
            )
        } catch {
            throw error
        }
    }
    
    func unlikePost(id: Int, userSession: UserSession) async throws -> Void {
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(String(describing: userSession.authToken))",
            "Content-Type": "application/json"
        ]
        
        do {
            return try await networkService.executeRequest(
                AF.request(Endpoints.Posts.like(postId: id),
                           method: .delete,
                           headers: headers
                          )
            )
        } catch {
            throw error
        }
    }
    
    func createPost(content: String, imageUrl: String?, userSession: UserSession) async throws -> PostDTO {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(String(describing: userSession.authToken))",
            "Content-Type": "application/json"
        ]
        
        let requestBody = CreatePostRequest(content: content, imageUrl: imageUrl)
        
        do {
            return try await networkService.executeRequest(
                AF.request(
                    Endpoints.Posts.posts,
                    method: .post,
                    parameters: requestBody,
                    encoder: JSONParameterEncoder.default,
                    headers: headers,
                )
            )
        } catch {
            throw error
        }
    }
}
