//
//  MulticastDelegate.swift
//
//  Created by JechtSh0t on 8/8/24.
//  Copyright © 2024 Brook Street Games. All rights reserved.
//

import Foundation

///
/// A collection of weakly referenced delegates.
///
actor MulticastDelegate<T: Sendable> {
    private let delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()
}

// MARK: - Operations -

extension MulticastDelegate {
    
    func add(_ delegate: T) {
        delegates.add(delegate as AnyObject)
    }

    func remove(_ delegate: T) {
        delegates.remove(delegate as AnyObject)
    }

    func invoke(_ invocation: @Sendable (T) async -> Void) async {
        for case let delegate as T in delegates.allObjects {
            await invocation(delegate)
        }
    }
}
