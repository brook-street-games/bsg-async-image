//
//  ImageLoaderViewTests.swift
//
//  Created by JechtSh0t on 5/22/23.
//  Copyright © 2023 Brook Street Games. All rights reserved.
//

import XCTest
@testable import BSGImageLoader

final class ImageLoaderViewTests: XCTestCase {
	
    private let waitTime: TimeInterval = 3.0
	private var testLoadSuccessExpectation: XCTestExpectation?
	private var testLoadFailureExpectation: XCTestExpectation?
	
	override func setUp() {
		NotificationCenter.default.removeObserver(self)
	}
}

extension ImageLoaderViewTests {
	
	func testLoadSuccess() {
		testLoadSuccessExpectation = expectation(description: "Test load success")
		
        let successImageView = UIImageView(image: UIImage(systemName: "checkmark"))
        let imageView = AsyncImageView(url: Constants.successImageURL1, loader: AsyncImageService(cacheType: .none), phaseHandler: { phase in
            switch phase {
            case .success: return successImageView
            default: return UIView()
            }
        })
		imageView.load()
		
		DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
            if imageView.subviews.contains(successImageView) { self.testLoadSuccessExpectation?.fulfill() }
		}
		waitForExpectations(timeout: waitTime)
	}
	
	func testLoadFailure() {
        testLoadFailureExpectation = expectation(description: "Test load failure")
        
        let failureImageView = UIImageView(image: UIImage(systemName: "xmark"))
        let imageView = AsyncImageView(url: Constants.failureImageURL, loader: AsyncImageService(cacheType: .none), phaseHandler: { phase in
            switch phase {
            case .failure: return failureImageView
            default: return UIView()
            }
        })
        imageView.load()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
            if imageView.subviews.contains(failureImageView) { self.testLoadFailureExpectation?.fulfill() }
        }
        waitForExpectations(timeout: waitTime)
	}
}
