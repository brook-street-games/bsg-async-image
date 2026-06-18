//
//  AsyncImage.swift
//
//  Created by JechtShot on 8/7/24.
//  Copyright © 2024 Brook Street Games. All rights reserved.
//

import SwiftUI

///
/// A view used to load and cache asynchronous images in SwiftUI.
///
public struct AsyncImage<Content: View>: View {

    // MARK: - Properties -

    private let url: URL
    private let imageService: AsyncImageServiceProtocol
    @ViewBuilder private let phaseHandler: (AsyncImagePhase) -> Content
    @State private var phase: AsyncImagePhase = .empty

    // MARK: - Initializers -

    public init(url: URL, imageService: AsyncImageServiceProtocol = AsyncImageService.shared, @ViewBuilder phaseHandler: @escaping (AsyncImagePhase) -> Content) {
        self.url = url
        self.imageService = imageService
        self.phaseHandler = phaseHandler
    }

    // MARK: - UI -

    public var body: some View {
        phaseHandler(phase)
            .task(id: url) {
                do {
                    let image = try await imageService.load(url)
                    phase = .success(Image(uiImage: image))
                } catch {
                    guard !Task.isCancelled else { return }
                    phase = .failure(error)
                }
            }
    }
}

// MARK: - Phase -

public enum AsyncImagePhase {
    case empty
    case success(Image)
    case failure(Error)
}

// MARK: - Preview -

#Preview {
    // The endpoint returns a random image every time. We force the view to re-render by using a slightly different size for each.
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
