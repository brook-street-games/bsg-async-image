//
//  AsyncImageViewTests.swift
//
//  Created by JechtShot on 5/22/23.
//  Copyright © 2023 Brook Street Games. All rights reserved.
//

import Testing
import UIKit
@testable import BSGAsyncImage

@MainActor
final class AsyncImageViewTests {}

// MARK: - Load -

extension AsyncImageViewTests {
	
	@Test func testLoadSuccess() async throws {
        let successImageView = UIImageView(image: UIImage(systemName: "checkmark"))
        let imageView = AsyncImageView(url: Constants.successImageURL1, imageService: AsyncImageService(cacheType: .none), phaseHandler: { phase in
            switch phase {
            case .success: return successImageView
            default: return UIView()
            }
        })
		imageView.load()
        try await Task.sleep(for: .seconds(Constants.waitTime))
        #expect(imageView.subviews.contains(successImageView))
	}
	
	@Test func testLoadFailure() async throws {
        let failureImageView = UIImageView(image: UIImage(systemName: "xmark"))
        let imageView = AsyncImageView(url: Constants.failureImageURL, imageService: AsyncImageService(cacheType: .none), phaseHandler: { phase in
            switch phase {
            case .failure: return failureImageView
            default: return UIView()
            }
        })
        imageView.load()
        try await Task.sleep(for: .seconds(Constants.waitTime))
        #expect(imageView.subviews.contains(failureImageView))
	}
}
