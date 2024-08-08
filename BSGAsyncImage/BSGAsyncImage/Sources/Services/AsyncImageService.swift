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
		/// The directory used when caching to disk.
		public static let diskCacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("bsg/images")
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
    /// Objects to alert when loading is complete.
    private var delegates = MulticastDelegate<AsyncImageServiceDelegate>()
	
    // MARK: - Shared -
    
    public static var shared = AsyncImageService(cacheType: .disk)
    
	// MARK: - Initializers -
	
	public init(cacheType: CacheType) {
		self.cacheType = cacheType
		if cacheType == .disk { createCacheDirectory() }
	}
}

// MARK: - Image Load -

extension AsyncImageService {
	
    ///
    /// Load an image. If *cacheType* is set to a value other than none and the image has been previously loaded, it will be taken from cache. Alerts all delegates when complete.
    ///  - parameter url: The source URL of the image.
    ///
	public func load(_ url: URL) {
		
        if let image = loadFromCache(url) {
            alertDelegates(response: AsyncImageResponse(url: url, result: .success(image)))
			return
		}
		
        guard !activeRequests.contains(url) else {
			return
		}
		
		let dataTask = self.session.dataTask(with: url) { data, response, error in
			DispatchQueue.main.async {
				self.activeRequests.remove(url)
				
				guard error == nil, let data = data, let image = UIImage(data: data) else {
                    self.alertDelegates(response: AsyncImageResponse(url: url, result: .failure(AsyncImageError.loadFailed)))
					return
				}
				
				self.saveToCache(image, url: url)
                self.alertDelegates(response: AsyncImageResponse(url: url, result: .success(image)))
			}
		}
				
		activeRequests.insert(url)
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
	/// Clear all caches.
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
	/// - parameter url: A source URL.
	/// - returns: A file name.
	///
	private func fileName(for url: URL) -> String? {
		return url.path.replacingOccurrences(of: "/", with: "_")
	}
}

// MARK: - Delegates -

extension AsyncImageService {
    
    ///
    /// Add a delegate to receive images.
    /// - parameter delegate: The object that will be added.
    ///
    public func addDelegate(_ delegate: AsyncImageServiceDelegate) {
        delegates.add(delegate)
    }
    
    ///
    /// Remove a delegate that will no longer receive images.
    /// - parameter delegate: The object that will be removed.
    ///
    public func removeDelegate(_ delegate: AsyncImageServiceDelegate) {
        delegates.remove(delegate)
    }
    
    ///
    /// Alert all delegates of a response.
    /// - parameter response: A response containing a loaded image.
    ///
    private func alertDelegates(response: AsyncImageResponse) {
        delegates.invoke { delegate in
            delegate.asyncImageService(self, didReceiveResponse: response)
        }
    }
}
