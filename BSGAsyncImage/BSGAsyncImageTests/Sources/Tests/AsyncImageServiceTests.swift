//
//  AsyncImageServiceTests2.swift
//
//  Created by JechtSh0t on 5/20/23.
//  Copyright © 2023 Brook Street Games. All rights reserved.
//

import Foundation
import Testing
@testable import BSGAsyncImage

@MainActor
final class AsyncImageServiceTests {
    private var delegateHandler: ((AsyncImageResponse) -> Void)?
}

// MARK: - Load -

extension AsyncImageServiceTests {

    @Test func testLoadSuccess() async {
        await confirmation("Test load success") { confirmed in
            delegateHandler  = { response in
                if case .success = response.result, response.url == Constant.successImageURL1 {
                    confirmed()
                }
            }

            let imageService = AsyncImageService(cacheType: .none)
            await imageService.addDelegate(self)
            await imageService.load(Constant.successImageURL1)
        }
    }

    @Test func testLoadFailure() async {
        await confirmation("Test load failure") { confirmed in
            delegateHandler = { response in
                if case .failure = response.result, response.url == Constant.failureImageURL {
                    confirmed()
                }
            }

            let imageService = AsyncImageService(cacheType: .none)
            await imageService.addDelegate(self)
            await imageService.load(Constant.failureImageURL)
        }
    }
}

// MARK: - Cache -

extension AsyncImageServiceTests {

    @Test func testCreateDiskCacheDirectory() async throws {
        try? FileManager.default.removeItem(atPath: AsyncImageService.Constant.diskCacheDirectory.path)
        _ = AsyncImageService(cacheType: .disk)
        try await Task.sleep(for: .seconds(Constant.waitTime))
        #expect(FileManager.default.fileExists(atPath: AsyncImageService.Constant.diskCacheDirectory.path))
    }

    @Test func testDiskCache() async throws {
        let imageService = AsyncImageService(cacheType: .disk)
        await imageService.clearCache()
        await imageService.load(Constant.successImageURL1)
        await imageService.load(Constant.successImageURL2)
        await imageService.load(Constant.successImageURL3)
        let contents = try FileManager.default.contentsOfDirectory(at: AsyncImageService.Constant.diskCacheDirectory, includingPropertiesForKeys: nil)
        #expect(contents.count == 3)
    }
}

// MARK: - Delegate -

extension AsyncImageServiceTests: AsyncImageServiceDelegate {

    func asyncImageService(_ service: AsyncImageService, didReceiveResponse response: AsyncImageResponse) {
        delegateHandler?(response)
    }
}
