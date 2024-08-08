//
//  AsyncImageViewModel.swift
//
//  Created by JechtSh0t on 8/7/24.
//  Copyright © 2024 Brook Street Games. All rights reserved.
//

import SwiftUI

public class AsyncImageViewModel: ObservableObject {
    
    // MARK: - Phase -
    
    public enum Phase {
        case empty
        case success(Image)
        case failure(Error)
    }
    
    // MARK: - Properties -
    
    let url: URL
    let imageService: AsyncImageServiceProtocol
    @Published var phase: Phase = .empty
    
    // MARK: - Initializers -
    
    public init(url: URL, imageService: AsyncImageServiceProtocol) {
        self.url = url
        self.imageService = imageService
        imageService.addDelegate(self)
    }
}

// MARK: - View Actions -

extension AsyncImageViewModel {
    
    func viewAppeared() {
        imageService.load(url)
    }
}

// MARK: - Image Handling -

extension AsyncImageViewModel: AsyncImageServiceDelegate {
    
    public func asyncImageService(_ service: AsyncImageService, didReceiveResponse response: AsyncImageResponse) {
        guard response.url == url else { return }
        switch response.result {
        case .success(let image): phase = .success(Image(uiImage: image))
        case .failure(let error): phase = .failure(error)
        }
    }
}
