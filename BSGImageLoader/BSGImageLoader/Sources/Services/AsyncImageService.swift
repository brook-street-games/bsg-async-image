//
//  ImageLoader.swift
//
//  Created by JechtSh0t on 5/20/23.
//  Copyright © 2023 Brook Street Games. All rights reserved.
//

import Foundation
import UIKit

///
/// A class used for asynchronous image loading.
///
public final class AsyncImageService: AsyncImageServiceProtocol {
	
    // MARK: - Constants -
    
	public struct Constants {
		/// The name of the notification posted when an image is loaded.
		public static let notificationName = "bsg.image"
		/// The notification parameter containing a **NotificationInfo** object.
		public static let notificationInfoParameter = "info"
		/// The cache directory when **cacheType** is set to disk.
		public static let diskCacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("bsg/images")
	}
	
	public enum Error: Swift.Error {
		case imageLoadFailed
	}
    
    // MARK: - Properties -
	
	/// The type of caching used for images.
	public private(set) var cacheType: CacheType
	
	/// The session used to loading all images.
	private lazy var session = URLSession(configuration: .ephemeral)
	/// The file manager instance used for caching to disk.
	private lazy var fileManager = FileManager.default
	/// Contains all URLs with an open data task.
    private var activeRequests = Set<URL>()
	/// Contains all images cached in memory.
	private var memoryCache = NSCache<NSString, UIImage>()
	
	// MARK: - Initializers -
	
	public init(cacheType: CacheType) {
		self.cacheType = cacheType
		if cacheType == .disk { createCacheDirectory() }
	}
}

// MARK: - Image Load -

extension AsyncImageService {
	
    ///
    /// Load an image. If *cacheType* is set to a value other than none and the image has been previously loaded, it will be taken from cache. When an image is loaded **imageLoaderNotification** will be posted containing a **NotificationInfo** which can be used to obtain the loaded image.
    ///
    ///  - parameter url: The source URL of the image.
    ///
	public func load(_ url: URL) {
		
        if let image = loadFromCache(url) {
			postNotification(info: NotificationInfo(url: url, result: .success(image)))
			return
		}
		
        guard !activeRequests.contains(url) else {
			return
		}
		
		let dataTask = self.session.dataTask(with: url) { data, response, error in
			
			DispatchQueue.main.async {
				
				self.activeRequests.remove(url)
				
				guard error == nil, let data = data, let image = UIImage(data: data) else {
					self.postNotification(info: NotificationInfo(url: url, result: .failure(Error.imageLoadFailed)))
					return
				}
				
				self.saveToCache(image, url: url)
				self.postNotification(info: NotificationInfo(url: url, result: .success(image)))
			}
		}
				
		self.activeRequests.insert(url)
		dataTask.resume()
    }
}

// MARK: - Cache -

extension AsyncImageService {
	
    public enum CacheType {
        /// Images will not be cached.
        case none
        /// Images will be cached to memory.
        case memory
        /// Images will be cached to disk under *documents/images*.
        case disk
    }
    
	///
	/// Create a directory for disk cache.
	///
	private func createCacheDirectory() {
		do {
			try fileManager.createDirectory(at: Constants.diskCacheDirectory, withIntermediateDirectories: true, attributes: [:])
		} catch {
			fatalError("Invalid disk cache directory.")
		}
	}
	
	///
	/// Save an image to cache.
	///
	/// - parameter image: An image.
	/// - parameter url: The source URL of the image.
	///
	private func saveToCache(_ image: UIImage, url: URL) {
		
		guard let imageName = fileName(for: url) else { return }
		
		switch cacheType {
		case .none: break
		case .memory: memoryCache.setObject(image, forKey: imageName as NSString)
		case .disk:
			let imageData = image.jpegData(compressionQuality: 1.0)
			let filePath = Constants.diskCacheDirectory.appendingPathComponent(imageName)
			fileManager.createFile(atPath: filePath.path, contents: imageData)
		}
	}
	
	///
	/// Load an image from cache.
	///
	/// - parameter url: The source URL of the image.
	/// - returns: A cached image.
	///
	private func loadFromCache(_ url: URL) -> UIImage? {
		
		guard let imageName = fileName(for: url) else { return nil }
		
		switch cacheType {
		case .none: return nil
		case .memory: return memoryCache.object(forKey: imageName as NSString)
		case .disk:
			guard let data = fileManager.contents(atPath: Constants.diskCacheDirectory.appendingPathComponent(imageName).path) else { return nil }
			return UIImage(data: data)
		}
	}
	
	///
	/// Clear all cache, ignoring the current value of **cacheType**.
	///
	public func clearCache() {
		
		memoryCache.removeAllObjects()
		
		if let contents = try? fileManager.contentsOfDirectory(at: Constants.diskCacheDirectory, includingPropertiesForKeys: nil) {
			for file in contents {
				try? fileManager.removeItem(at: file)
			}
		}
	}
}

// MARK: - File Name -

extension AsyncImageService {
	
	///
	/// Remove forward slashes from URL to create a disk-friendly file name.
	///
	/// - parameter url: A source URL.
	/// - returns: A file name.
	///
	private func fileName(for url: URL) -> String? {
		return url.path.replacingOccurrences(of: "/", with: "_")
	}
}

// MARK: - Notification -

extension AsyncImageService {
	
    public struct NotificationInfo {
        public var url: URL
        public var result: Result<UIImage, Error>
    }
    
	///
	/// Add an observer to *all* instances of **ImageLoader**.
	/// - warning: Calling this method more than once will result in duplicate notifications.
	///
	/// - parameter observer: The observing object.
	/// - parameter selector: The method that will be called to handle notifications.
	///
	public static func addObserver(_ observer: Any, selector: Selector) {
		NotificationCenter.default.addObserver(observer, selector: selector, name: Notification.Name(rawValue: Constants.notificationName), object: nil)
	}
	
    ///
    /// Post a notification to alert observers that an image load has completed.
    ///
    /// - parameter info: The notification info to pass.
    ///
	private func postNotification(info: NotificationInfo) {
		NotificationCenter.default.post(name: Notification.Name(Constants.notificationName), object: nil, userInfo: [Constants.notificationInfoParameter: info])
    }
}
