# BSGImageLoader

## Overview
A framework for asynchronous image loading based on notifications.

https://github.com/brook-street-games/bsg-image-loader/assets/72933425/6bda4dc9-db41-4574-8889-f6ae0cb2db65

## Installation

#### Requirements
+ iOS 13+

#### Swift Package Manager
1. Navigate to ***File->Add Packages***.
3. Enter Package URL: https://github.com/brook-street-games/bsg-image-loader.git
3. Select a dependency rule. **Up to Next Major** is recommended.
4. Select a project.
5. Select **Add Package**.

## Usage

#### Option #1: Use ImageLoaderView
```swift
/// Import the framework.
import BSGImageLoader

/// Create an instance of ImageLoader.
let imageLoader = ImageLoader(cache: .disk)

/// Create an instance of ImageLoaderView.
let imageLoaderView = ImageLoaderView()

/// Load an image.
imageLoaderView.load(<URL>, imageLoader: imageLoader)
```

#### Option #2: Use ImageLoader Directly
```swift
/// Import the framework.
import BSGImageLoader

/// Create an instance of ImageLoader.
let imageLoader = ImageLoader(cache: .disk)

/// Add an observer.
ImageLoader.addObserver(self, selector: #selector(handleNotification))

/// Load an image.
imageLoader.load(<URL>)

/// Handle notifications from ImageLoader. Since this method will be called for every image that is loaded, *info.url* should be checked before using the image. 
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
