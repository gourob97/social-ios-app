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
}
