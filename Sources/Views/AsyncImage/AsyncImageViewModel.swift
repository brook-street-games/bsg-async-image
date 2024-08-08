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
    let imageLoader: ImageLoader
    @Published var phase: Phase = .empty
    
    // MARK: - Initializers -
    
    public init(url: URL, imageLoader: ImageLoader) {
        self.url = url
        self.imageLoader = imageLoader
        ImageLoader.addObserver(self, selector: #selector(handleImage))
    }
}

// MARK: - View Actions -

extension AsyncImageViewModel {
    
    func imageAppeared() {
        imageLoader.load(url)
    }
}

// MARK: - Image Handling -

extension AsyncImageViewModel {
 
    @objc private func handleImage(_ notification: Notification) {
        guard let info = notification.userInfo?[ImageLoader.Constants.notificationInfoParameter] as? ImageLoader.NotificationInfo else { return }
        guard info.url == url else { return }

        switch info.result {
        case .success(let image): phase = .success(Image(uiImage: image))
        case .failure(let error): phase = .failure(error)
        }
    }
}
