//
//  CustomAsyncImage.swift
//  Social
//
//  Created by Gourob Mazumder on 4/11/25.
//

import SwiftUI

struct CustomAsyncImage: View {
    let url: URL
    let timeout: TimeInterval = TimeInterval(15) // 15 seconds timeout
    
    @State private var image: Image?
    @State private var hasError = false

    var body: some View {
        Group {
            if let image = image {
                image
                    .resizable()
                    .scaledToFit()
            } else if hasError {
                Color.gray
                    .overlay(Text("Failed to load"))
            } else {
                ZStack {
                    Color.clear
                    ProgressView()
                }
                .task {
                    await loadImage()
                }
            }
        }
        .frame(height: 300)
        .cornerRadius(8)
    }
    
    private func loadImage() async {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        let session = URLSession(configuration: configuration)
        
        do {
            let (data, _) = try await session.data(from: url)
            if let uiImage = UIImage(data: data) {
                image = Image(uiImage: uiImage)
            } else {
                hasError = true
            }
        } catch {
            hasError = true
        }
    }
}


#Preview {
    CustomAsyncImage(url: URL(string: "https://picsum.photos/400")!)
}
