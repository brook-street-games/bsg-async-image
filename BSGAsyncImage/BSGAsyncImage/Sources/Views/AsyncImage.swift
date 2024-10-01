//
//  AsyncImage.swift
//
//  Created by JechtSh0t on 8/7/24.
//  Copyright © 2024 Brook Street Games. All rights reserved.
//

import SwiftUI

///
/// A view used to load and cache asynchronous images in SwiftUI.
///
public struct AsyncImage<Content: View>: View {
    
    // MARK: - Properties -

    @ObservedObject private var phaseDelegate: AsyncImagePhaseDelegate
    @ViewBuilder private let phaseHandler: (AsyncImagePhase) -> Content
    
    // MARK: - Initializers -
    
    public init(url: URL, imageService: AsyncImageServiceProtocol = AsyncImageService.shared, @ViewBuilder phaseHandler: @escaping (AsyncImagePhase) -> Content) {
        self.phaseDelegate = AsyncImagePhaseDelegate(url: url, imageService: imageService)
        self.phaseHandler = phaseHandler
    }
    
    // MARK: - UI -
    
    public var body: some View {
        Group {
            phaseHandler(phaseDelegate.phase)
        }
        .onAppear {
            phaseDelegate.load()
        }
    }
}

// MARK: - Phase -

public enum AsyncImagePhase {
    case empty
    case success(Image)
    case failure(Error)
}

// MARK: - Phase Delegate -

@MainActor
public class AsyncImagePhaseDelegate: ObservableObject, AsyncImageServiceDelegate {
    
    // MARK: - Properties -
    
    let url: URL
    let imageService: AsyncImageServiceProtocol
    @Published var phase: AsyncImagePhase = .empty
    
    // MARK: - Initializers -
    
    public init(url: URL, imageService: AsyncImageServiceProtocol) {
        self.url = url
        self.imageService = imageService
        Task {
            await imageService.addDelegate(self)
        }
    }
    
    // MARK: - Image Handling -
    
    func load() {
        Task {
            await imageService.load(url)
        }
    }
    
    nonisolated public func asyncImageService(_ service: AsyncImageService, didReceiveResponse response: AsyncImageResponse) {
        Task { @MainActor in
            guard response.url == url else { return }
            switch response.result {
            case .success(let image): phase = .success(Image(uiImage: image))
            case .failure(let error): phase = .failure(error)
            }
        }
    }
}

// MARK: - Preview -

#Preview {
    // The URL returns a random image every time. We force the view to re-render by using a slightly different size for each.
    let urls = (100...199).map { URL(string: "https://picsum.photos/\($0)")! }
    let imageService = AsyncImageService(cacheType: .memory)
    ScrollView {
        LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
            ForEach(0..<100) { index in
                AsyncImage(url: urls[index], imageService: imageService) { phase in
                    switch phase {
                    case .empty: Rectangle().foregroundStyle(.black)
                    case .success(let image): image.resizable().aspectRatio(contentMode: .fill)
                    case .failure: Rectangle().foregroundStyle(.red)
                    }
                }
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
}
