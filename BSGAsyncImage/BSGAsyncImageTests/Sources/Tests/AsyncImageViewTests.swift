//
//  AsyncImageViewTests.swift
//
//  Created by JechtSh0t on 5/22/23.
//  Copyright © 2023 Brook Street Games. All rights reserved.
//

import XCTest
@testable import BSGAsyncImage

final class AsyncImageViewTests: XCTestCase {
	
    private let waitTime: TimeInterval = 3.0
}

extension AsyncImageViewTests {
	
    @MainActor
	func testLoadSuccess() async throws {
        let successImageView = UIImageView(image: UIImage(systemName: "checkmark"))
        let imageView = AsyncImageView(url: Constants.successImageURL1, imageService: AsyncImageService(cacheType: .none), phaseHandler: { phase in
            switch phase {
            case .success: return successImageView
            default: return UIView()
            }
        })
		imageView.load()
        try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
        XCTAssert(imageView.subviews.contains(successImageView))
	}
	
    @MainActor
	func testLoadFailure() async throws {
        let failureImageView = UIImageView(image: UIImage(systemName: "xmark"))
        let imageView = AsyncImageView(url: Constants.failureImageURL, imageService: AsyncImageService(cacheType: .none), phaseHandler: { phase in
            switch phase {
            case .failure: return failureImageView
            default: return UIView()
            }
        })
        imageView.load()
        try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
        XCTAssert(imageView.subviews.contains(failureImageView))
	}
}
