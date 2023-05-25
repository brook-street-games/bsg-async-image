//
//  UIView+Extensions.swift
//
//  Created by JechtSh0t on 5/21/23.
//  Copyright © 2023 Brook Street Games LLC. All rights reserved.
//

import UIKit

extension UIView {
	
	func roundCorners() {
		
		clipsToBounds = true
		layer.cornerRadius = 10
	}
	
	var systemBackgroundInverse: UIColor { traitCollection.userInterfaceStyle == .light ? .black : .white }
}
