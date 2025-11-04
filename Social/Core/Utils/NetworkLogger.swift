//
//  NetworkLogger.swift
//  Social
//
//  Created by Gourob Mazumder on 04/11/25.
//

import Foundation
import Alamofire

class NetworkLogger {
    static let shared = NetworkLogger()
    
    private init() {}
    
    // MARK: - Request Logging
    
    func logRequest<T: Codable>(
        url: String,
        method: HTTPMethod,
        headers: HTTPHeaders,
        body: T?
    ) {
        print("\n🌐 ==================== API REQUEST ====================")
        print("📍 URL: \(url)")
        print("🔧 Method: \(method.rawValue)")
        
        // Generate curl command
        let curlCommand = generateCurlCommand(
            url: url,
            method: method,
            headers: headers,
            body: body
        )
        print("💻 CURL Command:")
        print(curlCommand)
        
        print("📋 Headers:")
        for (key, value) in headers.dictionary {
            print("   \(key): \(value)")
        }
        
        if let body = body {
            print("📦 Request Body:")
            if let jsonData = try? JSONEncoder().encode(body),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print(formatJSON(jsonString))
            } else {
                print("   Failed to serialize body")
            }
        } else {
            print("📦 Request Body: None")
        }
        
        print("🌐 ====================================================\n")
    }
    
    // MARK: - Response Logging
    
    func logResponse(
        url: String,
        statusCode: Int?,
        headers: [AnyHashable: Any]?,
        data: Data?,
        error: Error?
    ) {
        print("\n📡 ==================== API RESPONSE ===================")
        print("📍 URL: \(url)")
        
        if let statusCode = statusCode {
            let statusEmoji = getStatusEmoji(statusCode)
            print("\(statusEmoji) Status Code: \(statusCode)")
        }
        
        if let headers = headers {
            print("📋 Response Headers:")
            for (key, value) in headers {
                print("   \(key): \(value)")
            }
        }
        
        if let data = data {
            print("📦 Raw Response Data (\(data.count) bytes):")
            if let jsonString = String(data: data, encoding: .utf8) {
                if isValidJSON(jsonString) {
                    print(formatJSON(jsonString))
                } else {
                    print("   \(jsonString)")
                }
            } else {
                print("   Unable to convert data to string")
            }
        } else {
            print("📦 Response Data: None")
        }
        
        if let error = error {
            print("❌ Error: \(error.localizedDescription)")
        }
        
        print("📡 ====================================================\n")
    }
    
    // MARK: - Helper Methods
    
    private func generateCurlCommand<T: Codable>(
        url: String,
        method: HTTPMethod,
        headers: HTTPHeaders,
        body: T?
    ) -> String {
        var curl = "curl -X \(method.rawValue)"
        
        // Add headers
        for (key, value) in headers.dictionary {
            curl += " \\\n  -H '\(key): \(value)'"
        }
        
        // Add body if present
        if let body = body,
           let jsonData = try? JSONEncoder().encode(body),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            let escapedJson = jsonString.replacingOccurrences(of: "'", with: "'\"'\"'")
            curl += " \\\n  -d '\(escapedJson)'"
        }
        
        // Add URL
        curl += " \\\n  '\(url)'"
        
        return curl
    }
    
    private func getStatusEmoji(_ statusCode: Int) -> String {
        switch statusCode {
        case 200...299:
            return "✅"
        case 300...399:
            return "↩️"
        case 400...499:
            return "⚠️"
        case 500...599:
            return "❌"
        default:
            return "❓"
        }
    }
    
    private func isValidJSON(_ string: String) -> Bool {
        guard let data = string.data(using: .utf8) else { return false }
        return (try? JSONSerialization.jsonObject(with: data)) != nil
    }
    
    private func formatJSON(_ jsonString: String) -> String {
        guard let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys]),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return jsonString
        }
        
        // Add indentation for better readability
        let lines = prettyString.components(separatedBy: .newlines)
        let indentedLines = lines.map { "   \($0)" }
        return indentedLines.joined(separator: "\n")
    }
}

// MARK: - Alamofire Integration

extension NetworkLogger {
    
    /// Logs an Alamofire DataRequest
    func logAlamofireRequest(_ request: DataRequest) {
        guard let urlRequest = request.request else { return }
        
        let url = urlRequest.url?.absoluteString ?? "Unknown URL"
        let method = HTTPMethod(rawValue: urlRequest.httpMethod ?? "GET")
        let headers = HTTPHeaders(urlRequest.allHTTPHeaderFields ?? [:])
        
        print("\n🌐 ==================== ALAMOFIRE REQUEST ====================")
        print("📍 URL: \(url)")
        print("🔧 Method: \(method.rawValue)")
        
        // Generate curl command
        let curlCommand = generateAlamofireCurlCommand(urlRequest: urlRequest)
        print("💻 CURL Command:")
        print(curlCommand)
        
        print("📋 Headers:")
        for (key, value) in headers.dictionary {
            print("   \(key): \(value)")
        }
        
        if let httpBody = urlRequest.httpBody,
           let bodyString = String(data: httpBody, encoding: .utf8) {
            print("📦 Request Body:")
            if isValidJSON(bodyString) {
                print(formatJSON(bodyString))
            } else {
                print("   \(bodyString)")
            }
        } else {
            print("📦 Request Body: None")
        }
        
        print("🌐 ============================================================\n")
    }
    
    private func generateAlamofireCurlCommand(urlRequest: URLRequest) -> String {
        guard let url = urlRequest.url else { return "Invalid URL" }
        
        var curl = "curl -X \(urlRequest.httpMethod ?? "GET")"
        
        // Add headers
        if let headers = urlRequest.allHTTPHeaderFields {
            for (key, value) in headers {
                curl += " \\\n  -H '\(key): \(value)'"
            }
        }
        
        // Add body if present
        if let httpBody = urlRequest.httpBody,
           let bodyString = String(data: httpBody, encoding: .utf8) {
            let escapedJson = bodyString.replacingOccurrences(of: "'", with: "'\"'\"'")
            curl += " \\\n  -d '\(escapedJson)'"
        }
        
        // Add URL
        curl += " \\\n  '\(url.absoluteString)'"
        
        return curl
    }
}
