//
//  MulticastDelegate.swift
//
//  Created by JechtSh0t on 8/8/24.
//  Copyright © 2024 Brook Street Games. All rights reserved.
//

import Foundation

///
/// Handles multiple delegates.
/// Source: https://tolgatanerstories.medium.com/a-better-pattern-than-notification-center-in-swift-f88f3a27afe6#:~:text=Cons%20Of%20The%20Notification%20Center,the%20weak%20hash%20table%20implementation.
///
actor MulticastDelegate<T> {
    private let delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()
}

// MARK: - Operations -

extension MulticastDelegate {
    
    func add(_ delegate: T) async {
        delegates.add(delegate as AnyObject)
    }

    func remove(_ target: T) async {
        for delegate in delegates.allObjects {
            if delegate === target as AnyObject {
                delegates.remove(delegate)
            }
        }
    }

    func invoke(_ invocation: (T) -> Void) async {
        for delegate in delegates.allObjects {
            invocation(delegate as! T)
        }
    }
}
