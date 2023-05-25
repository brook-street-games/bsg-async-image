//
//  UIImageView+Extensions.swift
//
//  Created by JechtSh0t on 5/21/23.
//  Copyright © 2023 Brook Street Games. All rights reserved.
//

import UIKit

extension UIImageView {
	
	/// Used to identify an activity indicator for removal.
	private var activityIndicatorIdentifier: String { "activityIndicator" }
	
	///
	/// Show an activity indicator.
	///
	/// - parameter activityIndicator: The activity indicator to show.
	///
	public func showActivityIndicator(_ activityIndicator: UIActivityIndicatorView) {
		
		hideActivityIndicator()
		
		addSubview(activityIndicator)
		
		activityIndicator.translatesAutoresizingMaskIntoConstraints = false
		activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
		activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
		activityIndicator.accessibilityIdentifier = activityIndicatorIdentifier
		activityIndicator.startAnimating()
	}
	
	///
	/// Hide and remove an existing activity indicator.
	///
	public func hideActivityIndicator() {
		
		if let activityIndicator = subviews.first(where: { $0.accessibilityIdentifier == activityIndicatorIdentifier }) as? UIActivityIndicatorView {
			activityIndicator.stopAnimating()
			activityIndicator.removeFromSuperview()
		}
	}
}

