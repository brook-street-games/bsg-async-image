//
//  AsyncImageServiceTests.swift
//
//  Created by JechtSh0t on 5/20/23.
//  Copyright © 2023 Brook Street Games. All rights reserved.
//

import XCTest
@testable import BSGAsyncImage

final class AsyncImageServiceTests: XCTestCase {
	
    private let waitTime: TimeInterval = 3.0
	private var testLoadSuccessExpectation: XCTestExpectation?
	private var testLoadFailureExpectation: XCTestExpectation?
}

// MARK: - Load -

extension AsyncImageServiceTests {
	
	func testLoadSuccess() async {
		testLoadSuccessExpectation = expectation(description: "Test load success")
		
		let imageService = AsyncImageService(cacheType: .none)
        await imageService.addDelegate(self)
		await imageService.load(Constants.successImageURL1)
		
        await fulfillment(of: [testLoadSuccessExpectation!], timeout: waitTime)
	}
	
	func testLoadFailure() async {
		testLoadFailureExpectation = expectation(description: "Test load failure")
		
        let imageService = AsyncImageService(cacheType: .none)
        await imageService.addDelegate(self)
        await imageService.load(Constants.failureImageURL)
		
        await fulfillment(of: [testLoadFailureExpectation!], timeout: waitTime)
	}
}

// MARK: - Cache -

extension AsyncImageServiceTests {
	
	func testCreateDiskCacheDirectory() async throws {
		try? FileManager.default.removeItem(atPath: AsyncImageService.Constants.diskCacheDirectory.path)
		_ = AsyncImageService(cacheType: .disk)
        try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
		XCTAssertTrue(FileManager.default.fileExists(atPath: AsyncImageService.Constants.diskCacheDirectory.path))
	}
	
	func testDiskCache() async throws {
		let imageService = AsyncImageService(cacheType: .disk)
        await imageService.clearCache()
        await imageService.load(Constants.successImageURL1)
        await imageService.load(Constants.successImageURL2)
        await imageService.load(Constants.successImageURL3)
		
        try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
        guard let contents = try? FileManager.default.contentsOfDirectory(at: AsyncImageService.Constants.diskCacheDirectory, includingPropertiesForKeys: nil) else { return }
        
        guard contents.count == 3 else {
            XCTAssertEqual(contents.count, 3)
            return
        }
	}
}

// MARK: - Image Handling -

extension AsyncImageServiceTests: AsyncImageServiceDelegate {
    
    func asyncImageService(_ service: AsyncImageService, didReceiveResponse response: AsyncImageResponse) {
        if case .success = response.result, response.url == Constants.successImageURL1 {
            self.testLoadSuccessExpectation?.fulfill()
        } else if case .failure = response.result, response.url == Constants.failureImageURL {
            self.testLoadFailureExpectation?.fulfill()
        }
    }
}
