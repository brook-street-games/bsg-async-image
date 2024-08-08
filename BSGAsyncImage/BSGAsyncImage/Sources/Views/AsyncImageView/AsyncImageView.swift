//
//  AsyncImageView.swift
//
//  Created by JechtSh0t on 5/21/23.
//  Copyright © 2023 Brook Street Games. All rights reserved.
//

import UIKit

///
/// A view used to load and cache asynchronous images in UIKit.
///
public class AsyncImageView<Content: UIView>: UIImageView {
    
    // MARK: - Phase -
    
    public enum Phase {
        case empty
        case success(UIImage)
        case failure(Error)
    }
    
    // MARK: - Properties -
    
    private let url: URL
    private let imageService: AsyncImageServiceProtocol
    private let phaseHandler: (Phase) -> Content
    private var phase: Phase = .empty { didSet { refresh() }}
    
    // MARK: - Initializers -
    
    public init(url: URL, imageService: AsyncImageServiceProtocol = AsyncImageService.shared, phaseHandler: @escaping (Phase) -> Content) {
        self.url = url
        self.imageService = imageService
        self.phaseHandler = phaseHandler
        
        super.init(frame: CGRect.zero)
        imageService.addDelegate(self)
        refresh()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        imageService.removeDelegate(self)
    }
}

// MARK: - Load -

extension AsyncImageView {
    
    ///
    /// Load an image ansynchronously. If the image has been previously cached, the cached image will be used.
    ///
    public func load() {
        phase = .empty
        imageService.load(url)
    }
}

// MARK: - Refresh -

extension AsyncImageView {
    
    ///
    /// Refresh subviews when the phase changes.
    ///
    private func refresh() {
        for subview in subviews { subview.removeFromSuperview() }
        let phaseView = phaseHandler(phase)
        phaseView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(phaseView)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[phaseView]|", metrics: nil, views: ["phaseView": phaseView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[phaseView]|", metrics: nil, views: ["phaseView": phaseView]))
    }
}

// MARK: - Image Handling -

extension AsyncImageView: AsyncImageServiceDelegate {
    
    public func asyncImageService(_ service: AsyncImageService, didReceiveResponse response: AsyncImageResponse) {
        guard response.url == url else { return }
        switch response.result {
        case .success(let image): phase = .success(image)
        case .failure(let error): phase = .failure(error)
        }
    }
}
