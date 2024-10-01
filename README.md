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
let asyncImageView = AsyncImageView(url: url) { phase in
	switch phase {
	case .empty:
	    // Configure a view for when the image is loading.
		let activityIndicator = UIActivityIndicatorView(style: .medium)
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
		view.backgroundColor = .red
		return view
	}
}
// Create an instance of ImageLoader.
let imageLoader = ImageLoader(cache: .disk)

// Create an instance of ImageLoaderView.
let imageLoaderView = ImageLoaderView()

// Load an image.
imageLoaderView.load(<URL>, imageLoader: imageLoader)
```

#### Use ImageLoader Directly

```swift
// Import the framework.
import BSGImageLoader

// Create an instance of ImageLoader.
let imageLoader = ImageLoader(cache: .disk)

// Add an observer.
ImageLoader.addObserver(self, selector: #selector(handleNotification))

// Load an image.
imageLoader.load(<URL>)

// Handle notifications from ImageLoader. Since this method will be called for every image that is loaded, the URL should be checked before using the image. 
@objc private func handleNotification(_ notification: Notification) {

	guard let info = notification.userInfo?[ImageLoader.Constants.notificationInfoParameter] as? ImageLoader.NotificationInfo else { return }
	
	// Check the URL.
	guard info.url == <URL> else { return }

	switch info.result {
	case .success(let image): 
		// Handle the image. 
	case .failure(let error: 
		// Handle the error.
	}
}
```

## Customization

#### Cache Types

* **None**. Images will not be cached.
* **Memory**. Images will be cached to memory, using NSCache.
* **Disk**. Images will be cached to disk in the ***documents/images*** directory.

#### Activity Indicator

```swift
let activityIndicator = UIActivityIndicatorView(style: .medium)
activityIndicator.color = .systemGreen
imageLoaderView.load(<URL>, imageLoader: imageLoader, activityIndicator: activityIndicator)
```

#### Default Image

```swift
imageLoaderView.load(<URL>, imageLoader: imageLoader, defaultImage: UIImage())
```

## Author

Brook Street Games LLC
