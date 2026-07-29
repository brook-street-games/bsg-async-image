//
//  AsyncImageServiceTests2.swift
//
//  Created by JechtShot on 5/20/23.
//  Copyright © 2023 Brook Street Games. All rights reserved.
//

import Foundation
import Testing
@testable import BSGAsyncImage

@MainActor
final class AsyncImageServiceTests {}

// MARK: - Load -

extension AsyncImageServiceTests {

    @Test func testLoadSuccess() async throws {
        let imageService = AsyncImageService(cacheType: .none)
        _ = try await imageService.load(Constants.successImageURL1)
    }

    @Test func testLoadFailure() async {
        let imageService = AsyncImageService(cacheType: .none)
        await #expect(throws: (any Error).self) {
            _ = try await imageService.load(Constants.failureImageURL)
        }
    }
}

// MARK: - Cache -

extension AsyncImageServiceTests {

    @Test func testCreateDiskCacheDirectory() async throws {
        let cacheDirectory = AsyncImageService(cacheType: .disk).cacheDirectory
        try FileManager.default.removeItem(atPath: cacheDirectory.path)
        _ = AsyncImageService(cacheType: .disk)
        try await Task.sleep(for: .seconds(Constants.waitTime))
        #expect(FileManager.default.fileExists(atPath: cacheDirectory.path))
    }

    @Test func testDiskCache() async throws {
        let imageService = AsyncImageService(cacheType: .disk)
        await imageService.clearCache()
        _ = try await imageService.load(Constants.successImageURL1)
        _ = try await imageService.load(Constants.successImageURL2)
        _ = try await imageService.load(Constants.successImageURL3)
        let contents = try FileManager.default.contentsOfDirectory(at: imageService.cacheDirectory, includingPropertiesForKeys: nil)
        #expect(contents.count == 3)
    }
}
