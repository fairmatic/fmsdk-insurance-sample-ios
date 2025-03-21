//
//  FairmaticManager.swift
//  FairmaticInsuranceSample
//
//  Created by Sagar Dagdu on 31/08/23.
//

import Foundation
import FairmaticSDK

typealias FairmaticCompletionHandler = (Bool, Error?) -> Void

final class FairmaticManager: NSObject {
    
    static let shared = FairmaticManager()
    
    #warning("Add your SDK key in the below line and remove this warning")
    private let sdkKey = ""
        
    private let fairmaticUserDefaults = FairmaticInsuranceUserDefaults.shared
    
    private override init() {}
    
    func initializeSDKForDriverId(driverId: String,
                                  successHandler: (() -> Void)?,
                                  failureHandler: ((NSError?) -> Void)?) {
        initializeSDKForDriverId(driverId: driverId,
                                 successHandler: successHandler,
                                 failureHandler: failureHandler,
                                 trialNumber: 1,
                                 totalRetryCount: 3)
    }
    
    func startPeriod1(completion: @escaping FairmaticCompletionHandler) {
        log.debug("Starting period 1")
        Fairmatic.startDriveWithPeriod1(completion)
    }
    
    func startPeriod2(completion: @escaping FairmaticCompletionHandler) {
        log.debug("Starting period 2")
        let trackingId = "P2-\(currentDateInMillis())"
        Fairmatic.startDriveWithPeriod2(trackingId, completionHandler: completion)
    }
    
    func startPeriod3(completion: @escaping FairmaticCompletionHandler) {
        log.debug("Starting period 3")
        let trackingId = "P3-\(currentDateInMillis())"
        Fairmatic.startDriveWithPeriod3(trackingId, completionHandler: completion)
    }
    
    func stopPeriod(completion: @escaping FairmaticCompletionHandler) {
        log.debug("Stopping period")
        Fairmatic.stopPeriod(completion)
    }
}

private extension FairmaticManager {
    func initializeSDKForDriverId(driverId: String,
                                          successHandler: (() -> Void)?,
                                          failureHandler: ((NSError?) -> Void)?,
                                          trialNumber: Int,
                                          totalRetryCount: Int) {
        let currentlyActiveInsurancePeriod = self.currentlyActiveInsurancePeriod
        log.debug("Initializing SDK for driver \(driverId) with current insurance period \(String(describing: currentlyActiveInsurancePeriod))")
        
        #warning("Replace the below driver attributes with your own driver attributes")
        let driverAttributes = DriverAttributes(
            firstName: "John",
            lastName: "Doe",
            email: "johndoe@company.com",
            phoneNumber: "+11234567890"
        )

        let configuration = Configuration(sdkKey: sdkKey,
                                          driverId: driverId,
                                          driverAttributes: driverAttributes)
        Fairmatic.setupWith(configuration: configuration) { (success, error) in
            let error: NSError? = error as NSError?
            if var error { // SDK initialization failed
                log.error("SDK initialization failed due to error: \(error.localizedDescription) at attempt \(trialNumber)/\(totalRetryCount)")
                // If the error occured due to network being unreachable, we retry. Else, we show the error to the user
                if (trialNumber < totalRetryCount), self.isErrorDueToNetworkUnreachable(error: error) {
                    self.initializeSDKForDriverId(driverId: driverId,
                                                  successHandler: successHandler,
                                                  failureHandler: failureHandler,
                                                  trialNumber: (trialNumber + 1),
                                                  totalRetryCount: totalRetryCount)
                } else {
                    error = self.getDisplayableError(fairmaticError: error)
                    failureHandler?(error);
                }
                
                return
            }
            
            log.debug("Fairmatic SDK initialization successful!")
            self.startAppropriateInsurancePeriodAtSDKInit { success, error in
                successHandler?()
            }
        }
    }
    
    func isErrorDueToNetworkUnreachable(error: NSError) -> Bool {
        return error.code == Int(FairmaticError.networkUnreachable.rawValue)
    }
    
    var currentlyActiveInsurancePeriod: Int? {
        if !fairmaticUserDefaults.isDriverOnDuty {
            return nil
        } else if fairmaticUserDefaults.isPassengerInCar {
            return 3
        } else if fairmaticUserDefaults.isPassengerWaitingForPickup {
            return 2
        } else {
            return 1
        }
    }
    
    private func getDisplayableError(fairmaticError: NSError) -> NSError {
        let error: NSError = fairmaticError as NSError
        var message: String = "Unknown error in setting up for insurance, please restart the " +
        "application. Please contact Fairmatic support if the issue persists"
        if (error.code == Int(FairmaticError.networkUnreachable.rawValue)) {
            message = "Internet not available to set up for insurance, please enable mobile data or connect to WiFi and restart the application";
        } else if error.code == Int(FairmaticError.invalidSDKKeyString.rawValue) {
            message = "Invalid SDK key, please contact Fairmatic support"
        }
        
        return NSError(domain: "FairmaticManager",
                       code: fairmaticError.code,
                       userInfo: [NSLocalizedFailureReasonErrorKey: message])
    }

    func startAppropriateInsurancePeriodAtSDKInit(completion: @escaping FairmaticCompletionHandler) {
        log.debug("Attempting to select proper insurance period at SDK init")
        
        guard let currentlyActiveInsurancePeriod = self.currentlyActiveInsurancePeriod else {
            log.debug("Insurance period could not be determined at SDK init, stopping periods")
            stopPeriod(completion: completion)
            return
        }
        
        log.debug("Insurance period \(currentlyActiveInsurancePeriod) determined at SDK init")
        
        switch currentlyActiveInsurancePeriod {
        case 1:
            startPeriod1(completion: completion)
        case 2:
            startPeriod2(completion: completion)
        case 3:
            startPeriod3(completion: completion)
        default:
            stopPeriod(completion: completion)
        }
    }
    
    func currentDateInMillis() -> Int64 {
        Int64(Date().timeIntervalSince1970 * 1000)
    }
}
