//
//  SampleViewModel.swift
//
//  Created by JechtShot on 5/21/23.
//  Copyright © 2023 Brook Street Games. All rights reserved.
//

import Foundation
import BSGAsyncImage

///
/// Data and functionality for the sample application.
///
@MainActor
final class SampleViewModel {
	
	// MARK: - Constants -
	
	private struct Constants {
		static let imageCount = 30
		static let cacheTypeKey = "cacheType"
		static let sampleImageURL = URL(string: "https://brookstreetgames.com/images.json")!
	}
	
	// MARK: - Properties -
	
	private var images = [SampleImage]()
	private(set) var displayedImages = [SampleImage]()
	private lazy var imageServiceCacheNone = AsyncImageService(cacheType: .none)
	private lazy var imageServiceCacheMemory = AsyncImageService(cacheType: .memory)
	private lazy var imageServiceCacheDisk = AsyncImageService(cacheType: .disk)
	
	var selectedCacheTypeIndex: Int { UserDefaults.standard.integer(forKey: Constants.cacheTypeKey) }
	var selectedCacheType: AsyncImageService.CacheType { cacheType(for: selectedCacheTypeIndex) }
	
	var imageService: AsyncImageService {
		switch selectedCacheType {
		case .none: return imageServiceCacheNone
		case .memory: return imageServiceCacheMemory
		case .disk: return imageServiceCacheDisk
		}
	}
}

// MARK: - Images -

extension SampleViewModel {
	
	func loadImages() async {
		debugPrint("Disk cache directory: \(imageService.cacheDirectory)")
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
            await imageService.clearCache()
        }
	}
}
