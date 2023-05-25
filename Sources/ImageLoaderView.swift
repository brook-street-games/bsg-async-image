//
//  ImageLoaderView.swift
//
//  Created by JechtSh0t on 5/21/23.
//  Copyright © 2023 Brook Street Games. All rights reserved.
//

import UIKit

///
/// A subclass of **UIImageView** that provides the asynchronous loading capabilities of **ImageLoader**.
///
public class ImageLoaderView: UIImageView {
	
	// MARK: - Properties -
	
	/// The source URL of the image to load.
	private var url: URL?
	/// Used when image loading fails for any reason.
	private var defaultImage: UIImage?
	
	// MARK: - Initializers -
	
	public init() {
		
		super.init(frame: CGRect.zero)
		ImageLoader.addObserver(self, selector: #selector(handleNotification))
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - Load -

extension ImageLoaderView {
	
	///
	/// Load an image ansynchronously from a URL. If the image has been previously cached, the image will be taken from there.
	///
	/// - parameter url: The source URL of the image to load.
	/// - parameter imageLoader: Used to load the image.
	/// - parameter activityIndicator: An optional activity indicator to show on the view while image loading is in progress.
	/// - parameter defaultImage: Used when image loading fails for any reason.
	///
	public func load(_ url: URL, imageLoader: ImageLoader, activityIndicator: UIActivityIndicatorView? = nil, defaultImage: UIImage? = nil) {
		
		self.url = url
		self.defaultImage = defaultImage
		
		if let activityIndicator = activityIndicator {
			showActivityIndicator(activityIndicator)
		}
		
		imageLoader.load(url)
	}
}

// MARK: - Result -

extension ImageLoaderView {
	
	///
	/// Handle notifications from **ImageLoader**.
	///
	/// - parameter notification: A notification posted after an image completes loading.
	///
	@objc private func handleNotification(_ notification: Notification) {
		
		guard let info = notification.userInfo?[ImageLoader.Constants.notificationInfoParameter] as? ImageLoader.NotificationInfo, info.url == url else { return }
		
		hideActivityIndicator()
		
		switch info.result {
		case .success(let image): self.image = image
		case .failure: self.image = defaultImage ?? self.image
		}
	}
}
