//
//  Date+Extensions.swift
//  FairmaticInsuranceSample
//
//  Created by Sagar Dagdu on 31/08/23.
//

import Foundation

extension Date {
    /// Returns the current timestamp in milliseconds
    /// - Returns: The current time in milliseconds
    static func currentMillis() -> Int64 {
        Int64(Date().timeIntervalSince1970 * 1000)
    }
}
