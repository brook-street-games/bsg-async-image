//
//  SampleViewModel.swift
//
//  Created by JechtSh0t on 5/21/23.
//  Copyright © 2023 Brook Street Games LLC. All rights reserved.
//

import Foundation
import BSGAsyncImage

///
/// Data and functionality for the sample application.
///
final class SampleViewModel {
	
	// MARK: - Constants -
	
	private struct Constants {
		static let imageCount = 30
		static let cacheTypeKey = "cacheType"
		static let sampleImageURL = URL(string: "https://brookstreetgames.com/images.txt")!
	}
	
	// MARK: - Properties -
	
	private var images = [SampleImage]()
	private(set) var displayedImages = [SampleImage]()
	private lazy var imageLoaderCacheNone = AsyncImageService(cacheType: .none)
	private lazy var imageLoaderCacheMemory = AsyncImageService(cacheType: .memory)
	private lazy var imageLoaderCacheDisk = AsyncImageService(cacheType: .disk)
	
	var selectedCacheTypeIndex: Int { UserDefaults.standard.integer(forKey: Constants.cacheTypeKey) }
	var selectedCacheType: AsyncImageService.CacheType { cacheType(for: selectedCacheTypeIndex) }
	
	var imageLoader: AsyncImageService {
		switch selectedCacheType {
		case .none: return imageLoaderCacheNone
		case .memory: return imageLoaderCacheMemory
		case .disk: return imageLoaderCacheDisk
		}
	}
}

// MARK: - Images -

extension SampleViewModel {
	
	func loadImages() async {
		debugPrint("Disk cache directory: \(AsyncImageService.Constants.diskCacheDirectory)")
        guard let (data, _) = try? await URLSession(configuration: .ephemeral).data(from: Constants.sampleImageURL) else { return }
        guard let images = try? JSONDecoder().decode(Array<SampleImage>.self, from: data) else { return }
        debugPrint("Loaded \(images.count) images from \(Constants.sampleImageURL)")
        self.images = images
        self.rollImages()
	}
	
	func rollImages() {
		displayedImages = Array(images.shuffled()[0..<Constants.imageCount])
	}
}

// MARK: - Cache -

extension SampleViewModel {
	
	func setCacheType(index: Int) {
		UserDefaults.standard.set(index, forKey: Constants.cacheTypeKey)
	}
	
	private func cacheType(for index: Int) -> AsyncImageService.CacheType {
		
		switch index {
		case 0: return .none
		case 1: return .memory
		case 2: return .disk
		default: fatalError("Invalid cache type index.")
		}
	}
	
	func clearCache() {
        Task {
            await imageLoader.clearCache()
        }
	}
}
