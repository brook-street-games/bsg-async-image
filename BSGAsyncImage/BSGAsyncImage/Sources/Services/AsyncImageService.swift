//
//  AsyncImageService.swift
//
//  Created by JechtSh0t on 5/20/23.
//  Copyright © 2023 Brook Street Games. All rights reserved.
//

import CryptoKit
import Foundation
import UIKit

public protocol AsyncImageServiceProtocol: Sendable {
    func load(_ url: URL) async
    func addDelegate(_ delegate: AsyncImageServiceDelegate) async
    func removeDelegate(_ delegate: AsyncImageServiceDelegate) async
}

public protocol AsyncImageServiceDelegate: AnyObject, Sendable {
    @MainActor func asyncImageService(_ service: AsyncImageService, didReceiveResponse response: AsyncImageResponse)
}

///
/// A service for asynchronous image loading.
///
public final actor AsyncImageService: AsyncImageServiceProtocol {
	
    // MARK: - Constants -
    
	public struct Constant {
		/// The directory used when caching to disk.
		public static let diskCacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("bsg/images")
	}
    
    // MARK: - Properties -
	
	/// The type of caching used for images.
	public private(set) var cacheType: CacheType
	
	/// The session used to load images.
	private lazy var session = URLSession(configuration: .ephemeral)
	/// The file manager instance used for caching to disk.
	private lazy var fileManager = FileManager.default
	/// Contains all URLs with an open data task.
    private var activeRequests = Set<URL>()
	/// Contains all images cached in memory.
	private var memoryCache = NSCache<NSString, UIImage>()
    /// Objects to alert when loading is complete.
    private let delegates = MulticastDelegate<AsyncImageServiceDelegate>()
	
    // MARK: - Shared -
    
    public static let shared = AsyncImageService(cacheType: .disk)
    
	// MARK: - Initializers -
	
	public init(cacheType: CacheType) {
		self.cacheType = cacheType
        if cacheType == .disk {
            Task {
                await createCacheDirectory()
            }
        }
	}
}

// MARK: - Image Load -

extension AsyncImageService {
	
    ///
    /// Load an image. If *cacheType* is set to a value other than none and the image has been previously loaded, it will be taken from cache. This method does not return a value, and instead alerts all delegates when complete.
    ///  - parameter url: The source URL of the image.
    ///
	public func load(_ url: URL) async {
        if let image = loadFromCache(url) {
            await alertDelegates(response: AsyncImageResponse(url: url, result: .success(image)))
			return
		}
		
        guard !activeRequests.contains(url) else {
			return
		}
        activeRequests.insert(url)
		
        do {
            let (data, _) = try await session.data(from: url)
            activeRequests.remove(url)
            
            guard let image = UIImage(data: data) else {
                await alertDelegates(response: AsyncImageResponse(url: url, result: .failure(AsyncImageError.decodingFailed)))
                return
            }
            
            saveToCache(image, url: url)
            await alertDelegates(response: AsyncImageResponse(url: url, result: .success(image)))
        } catch {
            await alertDelegates(response: AsyncImageResponse(url: url, result: .failure(AsyncImageError.downloadFailed(error))))
        }
    }
}

// MARK: - Cache -

extension AsyncImageService {
	
    public enum CacheType {
        /// Images will not be cached.
        case none
        /// Images will be cached to memory.
        case memory
        /// Images will be cached to both memory and disk.
        case disk
    }
    
	///
	/// Create a directory for disk cache.
	///
	private func createCacheDirectory() {
		do {
			try fileManager.createDirectory(at: Constant.diskCacheDirectory, withIntermediateDirectories: true, attributes: [:])
		} catch {
			fatalError("Invalid disk cache directory.")
		}
	}
	
	///
	/// Save an image to cache.
	/// - parameter image: An image.
	/// - parameter url: A source URL.
	///
	private func saveToCache(_ image: UIImage, url: URL) {
        let imageName = cacheKey(for: url)
		switch cacheType {
		case .none: break
		case .memory: memoryCache.setObject(image, forKey: imageName as NSString)
		case .disk:
			let imageData = image.jpegData(compressionQuality: 1.0)
			let filePath = Constant.diskCacheDirectory.appendingPathComponent(imageName)
			fileManager.createFile(atPath: filePath.path, contents: imageData)
            memoryCache.setObject(image, forKey: imageName as NSString)
		}
	}
    
    ///
    /// Hash a URL to create a cache key.
    /// - parameter url: A source URL.
    /// - returns: A cache key.
    ///
    private func cacheKey(for url: URL) -> String {
        let data = Data(url.absoluteString.utf8)
        let hash = SHA256.hash(data: data)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
	
	///
	/// Load an image from cache.
	/// - parameter url: A source URL.
	/// - returns: A cached image.
	///
	private func loadFromCache(_ url: URL) -> UIImage? {
		let imageName = cacheKey(for: url)
		switch cacheType {
		case .none: return nil
		case .memory: return memoryCache.object(forKey: imageName as NSString)
		case .disk:
            if let image = memoryCache.object(forKey: imageName as NSString) {
                return image
            } else {
                guard let data = fileManager.contents(atPath: Constant.diskCacheDirectory.appendingPathComponent(imageName).path) else { return nil }
                return UIImage(data: data)
            }
		}
	}
	
	///
	/// Clear all cached images.
	///
	public func clearCache() async {
		memoryCache.removeAllObjects()
		if let contents = try? fileManager.contentsOfDirectory(at: Constant.diskCacheDirectory, includingPropertiesForKeys: nil) {
			for file in contents {
				try? fileManager.removeItem(at: file)
			}
		}
	}
}

// MARK: - Delegates -

extension AsyncImageService {
    
    ///
    /// Add a delegate to receive images.
    /// - parameter delegate: The delegate that will be added.
    ///
    public func addDelegate(_ delegate: AsyncImageServiceDelegate) async {
        await delegates.add(delegate)
    }
    
    ///
    /// Stop a delegate from receiving images.
    /// - parameter delegate: The delegate that will be removed.
    ///
    public func removeDelegate(_ delegate: AsyncImageServiceDelegate) async {
        await delegates.remove(delegate)
    }
    
    ///
    /// Alert all delegates of a response.
    /// - parameter response: A response containing an image.
    ///
    private func alertDelegates(response: AsyncImageResponse) async {
        await delegates.invoke { delegate in
            await delegate.asyncImageService(self, didReceiveResponse: response)
        }
    }
}
