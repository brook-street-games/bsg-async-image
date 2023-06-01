//
//  ImageLoaderViewTests.swift
//
//  Created by JechtSh0t on 5/22/23.
//  Copyright © 2023 Brook Street Games. All rights reserved.
//

import XCTest
@testable import BSGImageLoader

final class ImageLoaderViewTests: XCTestCase {
	
	private var testLoadSuccessExpectation: XCTestExpectation?
	private var testLoadFailureExpectation: XCTestExpectation?
	private var testDefaultImageExpectation: XCTestExpectation?
	
	override func setUp() {
		NotificationCenter.default.removeObserver(self)
	}
}

extension ImageLoaderViewTests {
	
	func testLoadSuccess() {
		
		testLoadSuccessExpectation = expectation(description: "Test load success")
		
		let imageView = ImageLoaderView()
		imageView.load(TestConstants.successImageURL1, imageLoader: ImageLoader(cache: .none))
		
		DispatchQueue.main.asyncAfter(deadline: .now() + TestConstants.waitTime) {
			if imageView.image != nil { self.testLoadSuccessExpectation?.fulfill() }
		}
		waitForExpectations(timeout: TestConstants.waitTime)
	}
	
	func testLoadFailure() {
		
		testLoadFailureExpectation = expectation(description: "Test load failure")
		
		let imageView = ImageLoaderView()
		imageView.load(TestConstants.failureImageURL, imageLoader: ImageLoader(cache: .none))
		
		DispatchQueue.main.asyncAfter(deadline: .now() + TestConstants.waitTime) {
			if imageView.image == nil { self.testLoadFailureExpectation?.fulfill() }
		}
		waitForExpectations(timeout: TestConstants.waitTime)
	}
	
	func testDefaultImage() {
		
		testDefaultImageExpectation = expectation(description: "Test default image")
		
		let defaultImage = UIImage(systemName: "person")
		let imageView = ImageLoaderView()
		imageView.load(TestConstants.failureImageURL, imageLoader: ImageLoader(cache: .none), defaultImage: defaultImage)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + TestConstants.waitTime) {
			if imageView.image == defaultImage { self.testDefaultImageExpectation?.fulfill() }
		}
		waitForExpectations(timeout: TestConstants.waitTime)
	}
}
