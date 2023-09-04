//
//  FairmaticLiteLogger.swift
//  FairmaticInsuranceSample
//
//  Created by Sagar Dagdu on 04/09/23.
//

import Foundation

var log = FairmaticLiteLogger.self

/// A simple logger class
///
/// This is currently very crude and just prints out statements to the console in the debug mode.
final class FairmaticLiteLogger {
    private init() {}

    enum SDKLogLevel {
        case error
        case debug

        var initialCharacter: String {
            switch self {
            case .error:
                return "🚨"
            case .debug:
                return "🔧"
            }
        }
    }

    class func error(
        _ message: @autoclosure () -> Any,
        _ file: String = #file,
        _ function: String = #function,
        line: Int = #line
    ) {
        Self.internalLog(
            message(),
            level: .error,
            file,
            function,
            line: line
        )
    }

    class func debug(
        _ message: @autoclosure () -> Any,
        _ file: String = #file,
        _ function: String = #function,
        line: Int = #line
    ) {
        Self.internalLog(
            message(),
            level: .debug,
            file,
            function,
            line: line
        )
    }
}

private extension FairmaticLiteLogger {
    class func internalLog(
        _ message: @autoclosure () -> Any,
        level: SDKLogLevel,
        _ file: String = #file,
        _ function: String = #function,
        line: Int = #line
    ) {
        #if DEBUG
        print("\(level.initialCharacter) [\(fileString(from: file)):\(function):\(line)] \(message())\n")
        #endif
    }

    class func fileString(from file: String) -> String {
        (file as NSString).lastPathComponent
    }
}

