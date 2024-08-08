//
//  AsyncImageResponse.swift
//
//  Created by JechtSh0t on 8/8/24.
//  Copyright © 2024 Brook Street Games. All rights reserved.
//

import UIKit

public struct AsyncImageResponse {
    public var url: URL
    public var result: Result<UIImage, Error>
}
