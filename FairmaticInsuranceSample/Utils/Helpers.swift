//
//  Helpers.swift
//  FairmaticInsuranceSample
//
//  Created by Sagar Dagdu on 04/09/23.
//

import Foundation

/// Equivalent to `@synchronized` construct in Objective-C
/// - Parameters:
///   - lock: The object on which the lock is to be held
///   - closure: The closure to be synchronized
func synchronized(_ lock: Any,
                  closure: () -> ()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}
