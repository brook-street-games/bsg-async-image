# BSGImageLoader

## Overview

An iOS framework for asynchronous image loading. Includes configurable caching behavior, and a custom image view.

https://github.com/brook-street-games/bsg-image-loader/assets/72933425/39607948-6676-4f7b-a0de-897e40934baf

## Installation

#### Requirements

+ iOS 15+

#### Swift Package Manager

1. Navigate to ***File->Add Package Dependencies...***.
3. Enter package URL: https://github.com/brook-street-games/bsg-async-image.git
3. Select a dependency rule. **Up to Next Major Version** is recommended.
4. Select a project.
5. Select **Add Package**.

## Usage

```swift
// Import the framework.
import BSGAsyncImage
```

#### SwiftUI

```swift
// Create a view similar to Apple's [AsyncImage](https://developer.apple.com/documentation/swiftui/asyncimage). 
// By default images will cache to disk. Optionally provide an *AsyncImageService* to customize this.
AsyncImage(url: url) { phase in
	switch phase {
		case .empty: 
		    // Configure a view for when the image is loading.
		case .success(let image): 
			// Configure a view for when the image loads.
		case .failure(let error): 
			// Configure a way for when the image fails to load.
	}
}
```

#### UIKit

```swift
// Create a view. 
// By default images will cache to disk. Optionally provide an *AsyncImageService* to customize this.
let asyncImageView = AsyncImageView(url: url) { phase in
	switch phase {
	case .empty:
	    // Configure a view for when the image is loading.
		let activityIndicator = UIActivityIndicatorView(style: .medium)
		activityIndicator.color = .black
		activityIndicator.startAnimating()
		return activityIndicator
	case .success(let image):
		// Configure a view for when the image loads.
		let imageView = UIImageView(image: image)
		imageView.contentMode = .scaleAspectFill
		return imageView
	case .failure:
		// Configure a way for when the image fails to load.
		let view = UIView()
		view.backgroundColor = .black
		return view
	}
}
// Add the view to the hierarchy.
view.addSubview(asyncImageView)
// Load the image.
asyncImageView.load()

#### Custom Implementation

```swift
// Create an instance of *AsyncImageService*.
let asyncImageService = AsyncImageService(cacheType: .disk)

// Add a delegate. A multicast delegate pattern is used, this can be called for each object that needs to handle images.
await asyncImageService.addDelegate(self)
}
// Load an image.
await asyncImageLoader.load(url)

// Handle the result by conforming to *AsyncImageServiceDelegate*. Since this method will be called for every image that is loaded, the URL should be checked before using the image. 
nonisolated public func asyncImageService(_ service: AsyncImageService, didReceiveResponse response: AsyncImageResponse) {
	Task { @MainActor in
		// Check that the URL matches the one that was loaded.
		guard response.url == self.url else { return }
		switch response.result {
		case .success(let image): 
			// Handle the image. 
		case .failure(let error): 
			// Handle the error.
		}
	}
}
```

## Customization

#### Cache Types

* **None**. Images will not be cached.
* **Memory**. Images will be cached to memory using NSCache.
* **Disk**. Images will be cached to disk in the ***documents/images*** directory, and to memory using NSCache.

## Author

Brook Street Games LLC
