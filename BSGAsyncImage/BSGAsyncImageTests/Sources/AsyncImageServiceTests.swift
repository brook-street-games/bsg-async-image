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
	private var testDiskCacheExpectation: XCTestExpectation?
	
	override func setUp() {
		NotificationCenter.default.removeObserver(self)
	}
}

// MARK: - Load -

extension AsyncImageServiceTests {
	
	func testLoadSuccess() {
		testLoadSuccessExpectation = expectation(description: "Test load success")
		
		let imageService = AsyncImageService(cacheType: .none)
        imageService.addDelegate(self)
		imageService.load(Constants.successImageURL1)
		
		waitForExpectations(timeout: waitTime)
	}
	
	func testLoadFailure() {
		testLoadFailureExpectation = expectation(description: "Test load failure")
		
        let imageService = AsyncImageService(cacheType: .none)
        imageService.addDelegate(self)
		imageService.load(Constants.failureImageURL)
		
		waitForExpectations(timeout: waitTime)
	}
}

// MARK: - Cache -

extension AsyncImageServiceTests {
	
	func testCreateDiskCacheDirectory() {
		try? FileManager.default.removeItem(atPath: AsyncImageService.Constants.diskCacheDirectory.path)
		_ = AsyncImageService(cacheType: .disk)
		XCTAssertTrue(FileManager.default.fileExists(atPath: AsyncImageService.Constants.diskCacheDirectory.path))
	}
	
	func testDiskCache() {
		testDiskCacheExpectation = expectation(description: "Test disk cache")
		
		let imageLoader = AsyncImageService(cacheType: .disk)
		imageLoader.clearCache()
		imageLoader.load(Constants.successImageURL1)
		imageLoader.load(Constants.successImageURL2)
		imageLoader.load(Constants.successImageURL3)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
			guard let contents = try? FileManager.default.contentsOfDirectory(at: AsyncImageService.Constants.diskCacheDirectory, includingPropertiesForKeys: nil) else { return }
			
			guard contents.count == 3 else {
				XCTAssertEqual(contents.count, 3)
				return
			}
			
			self.testDiskCacheExpectation?.fulfill()
		}
		
		waitForExpectations(timeout: waitTime)
	}
}

// MARK: - Image Handling -

extension AsyncImageServiceTests: AsyncImageServiceDelegate {
    
    func asyncImageService(_ service: AsyncImageService, didReceiveResponse response: AsyncImageResponse) {
        if case .success = response.result, response.url == Constants.successImageURL1 {
            self.testLoadSuccessExpectation?.fulfill()
            self.testLoadSuccessExpectation = nil
        } else if case .failure = response.result, response.url == Constants.failureImageURL {
            self.testLoadFailureExpectation?.fulfill()
            self.testLoadFailureExpectation = nil
        }
    }
}
