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
	
    // MARK: - UI -
    
    /// Displays an image.
    private lazy var imageView: ImageLoaderView = {
		
		let imageView = ImageLoaderView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
	
	/// Displays the name of an image.
	private var nameLabel: UILabel = {
		
		let label = UILabel()
		label.backgroundColor = label.systemBackgroundInverse
		label.textColor = .systemBackground
		label.font = UIFont(name: "Marker Felt", size: Constants.fontSize)
		label.textAlignment = .center
		return label
	}()
    
    // MARK: - Setup -
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
		
		addSubview(imageView)
		imageView.translatesAutoresizingMaskIntoConstraints = false
		
		addSubview(nameLabel)
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		
		addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[imageView]|", metrics: nil, views: ["imageView": imageView]))
		addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[nameLabel]|", metrics: nil, views: ["nameLabel": nameLabel]))
		addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[imageView]|", metrics: nil, views: ["imageView": imageView]))
		addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=labelHeight)-[nameLabel(==labelHeight)]|", metrics: ["labelHeight": Constants.labelHeight], views: ["nameLabel": nameLabel]))
		
        roundCorners()
    }
    
	func configure(image: SampleImage, imageLoader: ImageLoader) {
        
        self.image = image
		
		backgroundColor = systemBackgroundInverse
		nameLabel.isHidden = image.name == nil
		nameLabel.text = image.name
		
		let activityIndicator = UIActivityIndicatorView(style: .medium)
		activityIndicator.color = .systemBackground
		imageView.load(image.url, imageLoader: imageLoader, activityIndicator: activityIndicator)
    }
	
	override func prepareForReuse() {
		
		super.prepareForReuse()
		
		imageView.image = nil
		nameLabel.isHidden = true
	}
}
