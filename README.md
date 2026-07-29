# BSGAsyncImage

A drop-in replacement for Apple's [AsyncImage](https://developer.apple.com/documentation/swiftui/asyncimage) with automatic caching.

https://github.com/user-attachments/assets/639b2a2a-33e7-4c0c-a49d-6a4fcd126bfe

## Requirements

+ iOS 15+

## Installation

### Swift Package Manager

1. Navigate to ***File->Add Package Dependencies...***.
3. Enter package URL: https://github.com/brook-street-games/bsg-async-image.git
3. Select a dependency rule. **Up to Next Major Version** is recommended.
4. Select a project.
5. Select **Add Package**.

## Usage

```swift
// Import the library.
import BSGAsyncImage
```

### SwiftUI

**AsyncImage** conforms to **View** and mirrors the API of [AsyncImage](https://developer.apple.com/documentation/swiftui/asyncimage).

```swift
AsyncImage(url: url) { phase in
	switch phase {
	// Configure a view for when the image load is in progress.
	case .empty: 
		ProgressView()
			.foregroundStyle(Color.black)
	// Configure a view for when the image load succeeds.
	case .success(let image): 
		image
			.resizable()
	// Configure a view for when the image load fails.
	case .failure(let error): 
		Rectangle()
			.foregroundStyle(Color.red)
	}
}
```

### UIKit

**AsyncImageView** is a subclass of **UIImageView** and mirrors the API of [AsyncImage](https://developer.apple.com/documentation/swiftui/asyncimage). 

```swift
let asyncImageView = AsyncImageView(url: url) { phase in
	switch phase {
	// Configure a view for when the image load is in progress.
	case .empty:
		let activityIndicator = UIActivityIndicatorView(style: .medium)
		activityIndicator.color = .black
		activityIndicator.startAnimating()
		return activityIndicator
	// Configure a view for when the image load succeeds.
	case .success(let image):
		let imageView = UIImageView(image: image)
		imageView.contentMode = .scaleAspectFill
		return imageView
	// Configure a view for when the image load fails.
	case .failure:
		let view = UIView()
		view.backgroundColor = .red
		return view
	}
}
// Add the view to the hierarchy.
view.addSubview(asyncImageView)
// Load the image.
asyncImageView.load()
```

## Customization

### Service

**AsyncImageService** can be provided as a parameter to either of the views above for more control. It can also be used on its own to handle receiving images directly.

```swift
// Create an instance of the service.
let asyncImageService = AsyncImageService(cacheType: .memory)

// Load an image.
do {
	let image = try await asyncImageService.load(url)
	// Handle the image.
} catch {
	// Handle the error.
}
```

### Cache Types

By default images are cached to disk. This can be changed when customizing a service.

* **Disk**. Images are cached to disk (***/bsg/images***).
* **Memory**. Images are cached to memory.
* **None**. Images are not cached.

## Author

Brook Street Games
