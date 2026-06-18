//
//  AsyncImageView.swift
//
//  Created by JechtShot on 5/21/23.
//  Copyright © 2023 Brook Street Games. All rights reserved.
//

import UIKit

///
/// A view used to load and cache asynchronous images in UIKit.
///
@MainActor
public class AsyncImageView: UIView {
    
    // MARK: - Phase -
    
    public enum Phase {
        case empty
        case success(UIImage)
        case failure(Error)
    }
    
    // MARK: - Properties -
    
    private let imageService: AsyncImageServiceProtocol
    private let phaseHandler: (Phase) -> UIView
    private var phase: Phase = .empty {
        didSet { refresh() }
    }
    private var task: Task<Void, Never>?
    private let url: URL

    // MARK: - Initializers -
    
    public init(url: URL, imageService: AsyncImageServiceProtocol = AsyncImageService.shared, phaseHandler: @escaping (Phase) -> UIView) {
        self.url = url
        self.imageService = imageService
        self.phaseHandler = phaseHandler
        super.init(frame: CGRect.zero)
        refresh()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        task?.cancel()
    }
}

// MARK: - Load -

extension AsyncImageView {
    
    ///
    /// Load an image asynchronously. If the image has been previously cached, the cached image will be used.
    ///
    public func load() {
        task?.cancel()
        task = Task { [weak self, imageService, url] in
            do {
                let image = try await imageService.load(url)
                guard let self else { return }
                self.phase = .success(image)
            } catch {
                guard let self, !Task.isCancelled else { return }
                self.phase = .failure(error)
            }
        }
    }
    
    ///
    /// Refresh subviews to reflect the current phase.
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
