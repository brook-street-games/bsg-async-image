//
//  AsyncImageService.swift
//
//  Created by JechtShot on 5/20/23.
//  Copyright © 2023 Brook Street Games. All rights reserved.
//

import CryptoKit
import Foundation
import UIKit

public protocol AsyncImageServiceProtocol: Sendable {
    func load(_ url: URL) async throws -> UIImage
    func clearCache() async
}

///
/// A service for asynchronous image loading.
///
public final actor AsyncImageService: AsyncImageServiceProtocol {
    
    // MARK: - Properties -

    /// The directory used when caching to disk.
    public nonisolated let cacheDirectory: URL = {
        let base = FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first
            ?? FileManager.default.temporaryDirectory
        return base.appendingPathComponent("bsg/images")
    }()
    /// The type of caching used for images.
    public nonisolated let cacheType: CacheType
    
    /// Contains all tasks that are in progress.
    private var activeTasks = [URL: Task<UIImage, Error>]()
    /// The file manager instance used for caching to disk.
    private let fileManager = FileManager.default
    /// Contains all images cached in memory.
    private var memoryCache = NSCache<NSString, UIImage>()
    /// The session used to load images.
    private lazy var session = URLSession(configuration: .ephemeral)
   
    // MARK: - Shared -
    
    public static let shared = AsyncImageService(cacheType: .disk)
    
	// MARK: - Initializers -
	
	public init(cacheType: CacheType) {
		self.cacheType = cacheType
        if cacheType == .disk {
            do {
                try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: [:])
            } catch {
                debugPrint("Failed to create disk cache directory.")
            }
        }
	}
}

// MARK: - Image Load -

extension AsyncImageService {

    ///
    /// Load an image. If caching is enabled and the image is in the cache, the cached image is returned. Multiple callers requesting the same URL share a request.
    /// - parameter url: A source URL.
    /// - returns: An image.
    ///
    public func load(_ url: URL) async throws -> UIImage {
        if let image = loadFromCache(url) {
            return image
        }

        if let task = activeTasks[url] {
            return try await task.value
        }

        let task = Task<UIImage, Error> {
            let (data, _) = try await session.data(from: url)
            guard let image = UIImage(data: data) else {
                throw AsyncImageError.decodingFailed
            }
            saveToCache(image, data: data, url: url)
            return image
        }
        activeTasks[url] = task
        defer {
            activeTasks[url] = nil
        }
        return try await task.value
    }
}

// MARK: - Cache -

extension AsyncImageService {
	
    public enum CacheType: Sendable {
        /// Images will not be cached.
        case none
        /// Images will be cached to memory.
        case memory
        /// Images will be cached to both memory and disk.
        case disk
    }
	
	///
	/// Save an image to the cache.
	/// - parameter image: An image.
    /// - parameter data: Raw image data.
	/// - parameter url: A source URL.
	///
    private func saveToCache(_ image: UIImage, data: Data, url: URL) {
        let key = cacheKey(for: url)
		switch cacheType {
		case .none: break
		case .disk:
			let filePath = cacheDirectory.appendingPathComponent(key)
			fileManager.createFile(atPath: filePath.path, contents: data)
            fallthrough
        case .memory:
            memoryCache.setObject(image, forKey: key as NSString)
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
	/// Load an image from the cache.
	/// - parameter url: A source URL.
	/// - returns: A cached image.
	///
	private func loadFromCache(_ url: URL) -> UIImage? {
		let key = cacheKey(for: url)
		switch cacheType {
		case .none: return nil
		case .memory: return memoryCache.object(forKey: key as NSString)
		case .disk:
            if let image = memoryCache.object(forKey: key as NSString) {
                return image
            } else {
                guard let data = fileManager.contents(atPath: cacheDirectory.appendingPathComponent(key).path) else { return nil }
                return UIImage(data: data)
            }
		}
	}
	
	///
	/// Clear all cached images.
	///
	public func clearCache() async {
		memoryCache.removeAllObjects()
		if let contents = try? fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil) {
			for file in contents {
				try? fileManager.removeItem(at: file)
			}
		}
	}
}
