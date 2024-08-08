//
//  SampleCell.swift
//
//  Created by JechtSh0t on 5/20/23.
//  Copyright © 2023 Brook Street Games LLC. All rights reserved.
//

import UIKit
import BSGImageLoader

///
/// A cell displaying a sample image.
///
final class SampleCell: UICollectionViewCell {
    
	// MARK: - Constants -
	
	private struct Constants {
		static let fontSize: CGFloat = 16
		static let labelHeight: CGFloat = 24
	}
	
    // MARK: - Properties -
    
    private var image: SampleImage!
    private var imageLoader: AsyncImageService!
	
    // MARK: - UI -
    
	/// Displays the name of an image.
	private lazy var nameLabel: UILabel = {
		let label = UILabel()
		label.backgroundColor = label.systemBackgroundInverse
		label.textColor = .systemBackground
		label.font = UIFont(name: "Lexend", size: Constants.fontSize)
		label.textAlignment = .center
		return label
	}()
    
    // MARK: - Setup -
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
	func configure(image: SampleImage, imageLoader: AsyncImageService) {
        self.image = image
        self.imageLoader = imageLoader
		
		backgroundColor = systemBackgroundInverse
        roundCorners()
        
        let imageView = createImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.load()
        addSubview(imageView)
        
        addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
		nameLabel.isHidden = image.name == nil
		nameLabel.text = image.name
		
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", metrics: nil, views: ["imageView": imageView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[nameLabel]|", metrics: nil, views: ["nameLabel": nameLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", metrics: nil, views: ["imageView": imageView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=labelHeight)-[nameLabel(==labelHeight)]|", metrics: ["labelHeight": Constants.labelHeight], views: ["nameLabel": nameLabel]))
    }
	
	override func prepareForReuse() {
		super.prepareForReuse()
        for subview in subviews { subview.removeFromSuperview() }
	}
}

// MARK: - Image View -

extension SampleCell {
    
    private func createImageView() -> AsyncImageView<UIView> {
        return AsyncImageView(url: image.url, imageService: imageLoader) { phase in
            switch phase {
            case .empty:
                let activityIndicator = UIActivityIndicatorView(style: .medium)
                activityIndicator.color = .systemBackground
                activityIndicator.startAnimating()
                return activityIndicator
            case .success(let image):
                let imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFill
                return imageView
            case .failure:
                return UIView()
            }
        }
    }
}
