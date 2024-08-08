//
//  ImageLoaderTests.swift
//
//  Created by JechtSh0t on 5/20/23.
//  Copyright © 2023 Brook Street Games. All rights reserved.
//

import XCTest
@testable import BSGImageLoader

final class ImageLoaderTests: XCTestCase {
	
    private let waitTime: TimeInterval = 3.0
	private var testLoadSuccessExpectation: XCTestExpectation?
	private var testLoadFailureExpectation: XCTestExpectation?
	private var testDiskCacheExpectation: XCTestExpectation?
	
	override func setUp() {
		NotificationCenter.default.removeObserver(self)
	}
}

// MARK: - Load -

extension ImageLoaderTests {
	
	func testLoadSuccess() {
		AsyncImageService.addObserver(self, selector: #selector(loadSuccessCompletion))
		testLoadSuccessExpectation = expectation(description: "Test load success")
		
		let imageLoader = AsyncImageService(cacheType: .none)
		imageLoader.load(Constants.successImageURL1)
		
		waitForExpectations(timeout: waitTime)
	}
	
	@objc func loadSuccessCompletion(_ notification: Notification) {
		guard let result = notification.userInfo?[AsyncImageService.Constants.notificationInfoParameter] as? AsyncImageService.NotificationInfo else { return }
		
		if case .success = result.result, result.url == Constants.successImageURL1 {
			self.testLoadSuccessExpectation?.fulfill()
			self.testLoadSuccessExpectation = nil
		}
	}
	
	func testLoadFailure() {
		AsyncImageService.addObserver(self, selector: #selector(loadFailureCompletion))
		testLoadFailureExpectation = expectation(description: "Test load failure")
		
		let imageLoader = AsyncImageService(cacheType: .none)
		imageLoader.load(Constants.failureImageURL)
		
		waitForExpectations(timeout: waitTime)
	}
	
	@objc func loadFailureCompletion(_ notification: Notification) {
		guard let result = notification.userInfo?[AsyncImageService.Constants.notificationInfoParameter] as? AsyncImageService.NotificationInfo else { return }
		
		if case .failure(let error) = result.result, result.url == Constants.failureImageURL, error == .imageLoadFailed {
			self.testLoadFailureExpectation?.fulfill()
			self.testLoadFailureExpectation = nil
		}
	}
}

// MARK: - Cache -

extension ImageLoaderTests {
	
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
