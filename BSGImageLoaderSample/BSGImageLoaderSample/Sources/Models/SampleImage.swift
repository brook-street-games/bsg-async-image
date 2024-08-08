//
//  SampleImage.swift
//
//  Created by JechtSh0t on 5/21/23.
//  Copyright © 2023 Brook Street Games LLC. All rights reserved.
//

import Foundation

///
/// An image for the sample application.
///
struct SampleImage: Codable {
	
	var name: String?
	var source: String
	
	var url: URL { URL(string: source)! }
}
