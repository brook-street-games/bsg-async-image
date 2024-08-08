//
//  AsyncImageView.swift
//
//  Created by JechtSh0t on 5/21/23.
//  Copyright © 2023 Brook Street Games. All rights reserved.
//

import UIKit
import SwiftUI

///
/// A subclass of **UIImageView** that provides the asynchronous loading capabilities of **ImageLoader**.
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
    private let loader: AsyncImageService
    private let phaseHandler: (Phase) -> Content
    private var phase: Phase = .empty { didSet { refresh() }}
    
    // MARK: - Initializers -
    
    public init(url: URL, loader: AsyncImageService, phaseHandler: @escaping (Phase) -> Content) {
        self.url = url
        self.loader = loader
        self.phaseHandler = phaseHandler
        
        super.init(frame: CGRect.zero)
        AsyncImageService.addObserver(self, selector: #selector(handleNotification))
        refresh()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Image Handling -
    
    ///
    /// Handle notifications from **ImageLoader**.
    ///
    /// - parameter notification: A notification posted after an image completes loading.
    ///
    @objc private func handleNotification(_ notification: Notification) {
        guard let info = notification.userInfo?[AsyncImageService.Constants.notificationInfoParameter] as? AsyncImageService.NotificationInfo, info.url == url else { return }
        
        switch info.result {
        case .success(let image): phase = .success(image)
        case .failure(let error): phase = .failure(error)
        }
    }
}

// MARK: - Load -

extension AsyncImageView {
    
    ///
    /// Load an image ansynchronously. If the image has been previously cached, the cached image will be used.
    ///
    public func load() {
        phase = .empty
        loader.load(url)
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
