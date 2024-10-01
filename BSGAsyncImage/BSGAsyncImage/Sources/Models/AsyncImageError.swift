//
//  AsyncImageError.swift
//
//  Created by JechtSh0t on 8/8/24.
//  Copyright © 2024 Brook Street Games. All rights reserved.
//

public enum AsyncImageError: Error {
    case invalidImageData
    case requestFailed(Error)
}
