//
//  AsyncImage.swift
//
//  Created by JechtSh0t on 8/7/24.
//  Copyright © 2024 Brook Street Games. All rights reserved.
//

import SwiftUI

public struct AsyncImage<Content: View>: View {
    
    // MARK: - Properties -
    
    @ObservedObject private var viewModel: AsyncImageViewModel
    @ViewBuilder private let phaseHandler: (AsyncImageViewModel.Phase) -> Content
    
    // MARK: - Initializers -
    
    public init(url: URL, loader: ImageLoader, @ViewBuilder phaseHandler: @escaping (AsyncImageViewModel.Phase) -> Content) {
        self.viewModel = AsyncImageViewModel(url: url, imageLoader: loader)
        self.phaseHandler = phaseHandler
    }
    
    // MARK: - UI -
    
    public var body: some View {
        Group {
            phaseHandler(viewModel.phase)
        }
        .onAppear(perform: viewModel.imageAppeared)
    }
}

// MARK: - Preview -

#Preview {
    let url = Constants.successImageURL1
    let loader = ImageLoader(cacheType: .memory)
    return AsyncImage(url: url, loader: loader) { phase in
        switch phase {
        case .empty: Rectangle().foregroundStyle(.black)
        case .success(let image): image.resizable().aspectRatio(contentMode: .fill)
        case .failure: Rectangle().foregroundStyle(.red)
        }
    }
    .frame(width: 200, height: 200)
    .clipShape(RoundedRectangle(cornerRadius: 10))
}
