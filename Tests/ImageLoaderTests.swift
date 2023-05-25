//
//  ImageLoaderTests.swift
//
//  Created by JechtSh0t on 5/20/23.
//  Copyright © 2023 Brook Street Games. All rights reserved.
//

import XCTest
@testable import BSGImageLoader

final class ImageLoaderTests: XCTestCase {
	
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
		
		ImageLoader.addObserver(self, selector: #selector(loadSuccessCompletion))
		testLoadSuccessExpectation = expectation(description: "Test load success")
		
		let imageLoader = ImageLoader(cacheType: .none)
		imageLoader.load(TestConstants.successImageURL1)
		
		waitForExpectations(timeout: TestConstants.waitTime)
	}
	
	@objc func loadSuccessCompletion(_ notification: Notification) {
		
		guard let result = notification.userInfo?[ImageLoader.Constants.notificationInfoParameter] as? ImageLoader.NotificationInfo else { return }
		
		if case .success = result.result, result.url == TestConstants.successImageURL1 {
			self.testLoadSuccessExpectation?.fulfill()
			self.testLoadSuccessExpectation = nil
		}
	}
	
	func testLoadFailure() {
		
		ImageLoader.addObserver(self, selector: #selector(loadFailureCompletion))
		testLoadFailureExpectation = expectation(description: "Test load failure")
		
		let imageLoader = ImageLoader(cacheType: .none)
		imageLoader.load(TestConstants.failureImageURL)
		
		waitForExpectations(timeout: TestConstants.waitTime)
	}
	
	@objc func loadFailureCompletion(_ notification: Notification) {
		
		guard let result = notification.userInfo?[ImageLoader.Constants.notificationInfoParameter] as? ImageLoader.NotificationInfo else { return }
		
		if case .failure(let error) = result.result, result.url == TestConstants.failureImageURL, error == .imageLoadFailed {
			self.testLoadFailureExpectation?.fulfill()
			self.testLoadFailureExpectation = nil
		}
	}
}

// MARK: - Cache -

extension ImageLoaderTests {
	
	func testCreateDiskCacheDirectory() {
		
		try? FileManager.default.removeItem(atPath: ImageLoader.Constants.diskCacheDirectory.path)
		_ = ImageLoader(cacheType: .disk)
		XCTAssertTrue(FileManager.default.fileExists(atPath: ImageLoader.Constants.diskCacheDirectory.path))
	}
	
	func testDiskCache() {
		
		testDiskCacheExpectation = expectation(description: "Test disk cache")
		
		let imageLoader = ImageLoader(cacheType: .disk)
		imageLoader.clearCache()
		imageLoader.load(TestConstants.successImageURL1)
		imageLoader.load(TestConstants.successImageURL2)
		imageLoader.load(TestConstants.successImageURL3)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + TestConstants.waitTime) {
			
			guard let contents = try? FileManager.default.contentsOfDirectory(at: ImageLoader.Constants.diskCacheDirectory, includingPropertiesForKeys: nil) else { return }
			
			guard contents.count == 3 else {
				XCTAssertEqual(contents.count, 3)
				return
			}
			
			self.testDiskCacheExpectation?.fulfill()
		}
		
		waitForExpectations(timeout: TestConstants.waitTime)
	}
}
