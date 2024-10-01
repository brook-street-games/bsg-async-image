//
//  AsyncImageServiceProtocol.swift
//
//  Created by JechtSh0t on 8/8/24.
//  Copyright © 2024 Brook Street Games. All rights reserved.
//

import Foundation

///
/// A set of rules for asynchronous image loading.
///
public protocol AsyncImageServiceProtocol {
    func load(_ url: URL) async
    func addDelegate(_ delegate: AsyncImageServiceDelegate) async
    func removeDelegate(_ delegate: AsyncImageServiceDelegate) async
}
