//
//  AsyncImageServiceDelegate.swift
//
//  Created by JechtSh0t on 8/8/24.
//  Copyright © 2024 Brook Street Games. All rights reserved.
//

import UIKit

///
/// A set of rules for asynchronous image handling.
///
public protocol AsyncImageServiceDelegate {
    func asyncImageService(_ service: AsyncImageService, didReceiveResponse response: AsyncImageResponse)
}
