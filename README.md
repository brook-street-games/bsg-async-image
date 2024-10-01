# BSGImageLoader

## Overview

An iOS framework for asynchronous image loading, and caching.

https://github.com/user-attachments/assets/639b2a2a-33e7-4c0c-a49d-6a4fcd126bfe

## Installation

### Requirements

+ iOS 15+

### Swift Package Manager

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

### SwiftUI

**AsyncImage** conforms to **View** with a similar style to Apple's [AsyncImage](https://developer.apple.com/documentation/swiftui/asyncimage).
By default images will cache to disk. Optionally provide an **AsyncImageService** to customize this.

```swift
AsyncImage(url: url) { phase in
	switch phase {
	// Configure a view for when the image is loading.
	case .empty: 
		ProgressView()
			.foregroundStyle(Color.black)
	// Configure a view for when the image loads.
	case .success(let image): 
		image
			.resizable()
	// Configure a way for when the image fails to load.
	case .failure(let error): 
		Rectangle()
			.foregroundStyle(Color.black)
	}
}
```

### UIKit

**AsyncImageView** is a subclass of **UIImageView** built with a similar style to Apple's [AsyncImage](https://developer.apple.com/documentation/swiftui/asyncimage). 
By default images will cache to disk. Optionally provide an **AsyncImageService** to customize this.

```swift
let asyncImageView = AsyncImageView(url: url) { phase in
	switch phase {
	// Configure a view for when the image is loading.
	case .empty:
		let activityIndicator = UIActivityIndicatorView(style: .medium)
		activityIndicator.color = .black
		activityIndicator.startAnimating()
		return activityIndicator
	// Configure a view for when the image loads.
	case .success(let image):
		let imageView = UIImageView(image: image)
		imageView.contentMode = .scaleAspectFill
		return imageView
	// Configure a way for when the image fails to load.
	case .failure:
		let view = UIView()
		view.backgroundColor = .black
		return view
	}
}
// Add the view to the hierarchy.
view.addSubview(asyncImageView)
// Load the image.
asyncImageView.load()
```

### Service

**AsyncImageService** can be used directly to handle receiving images in cases where the views above are not sufficient.

```swift
// Create an instance of the service.
let asyncImageService = AsyncImageService(cacheType: .disk)

// Add a delegate. A multicast delegate pattern is used.
await asyncImageService.addDelegate(self)
}
// Load an image.
await asyncImageService.load(url)

// Handle the result by conforming to *AsyncImageServiceDelegate*. Since this method will be called for every image that is loaded, the URL should be checked before using the image. 
nonisolated public func asyncImageService(_ service: AsyncImageService, didReceiveResponse response: AsyncImageResponse) {
	Task { @MainActor in
		// Check that the URLs match.
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

### Cache Types

* **None**. Images will not be cached.
* **Memory**. Images will be cached to memory using NSCache.
* **Disk**. Images will be cached to disk in the ***documents/images*** directory, and to memory using NSCache.

## Author

Brook Street Games LLC
