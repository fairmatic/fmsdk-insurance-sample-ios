//
//  Logger.swift
//  FairmaticInsuranceSample
//
//  Created by Sagar Dagdu on 01/09/23.
//
import Foundation
import SwiftyBeaver

/// Global log object used for logging anywhere in the application
let log = SwiftyBeaver.self

/// Properties for the logger that we configure using `SwiftyBeaver`
enum LoggerProperties {
    /// The maximum size a log file can get to (10 MB)
    static let logFileMaxSize = 10 * 1024 * 1024

    /// The filename used for log
    static let logFileName = "fairmatic-insurance-sample.log"

    /// The format used for the logs printed in the Xcode console
    ///
    /// More context can be found [here](https://docs.swiftybeaver.com/article/20-custom-format)
    static let consoleLogFormatString = "$Dhh:mm:ss a$d $C$L$c $N.$F:$l - $M"

    /// The format used for the logs written to the log file
    ///
    /// More context can be found [here](https://docs.swiftybeaver.com/article/20-custom-format)
    static let fileLogFormatString = "$Ddd-MMM-yy hh:mm:ss a$d $C$L$c $N.$F:$l - $M"
}

/// Global level function to configure logger.
/// Takes care of checking the debug configuration before initializing the logger.
func configureLoggerIfNeeded() {
    let consoleDestination = ConsoleDestination()

    consoleDestination.format = LoggerProperties.consoleLogFormatString

    consoleDestination.levelColor.verbose = "✉️ "
    consoleDestination.levelColor.debug = "🍕 "
    consoleDestination.levelColor.info = "ℹ️ "
    consoleDestination.levelColor.warning = "⚠️ "
    consoleDestination.levelColor.error = "🚨 "

    log.addDestination(consoleDestination)
}
