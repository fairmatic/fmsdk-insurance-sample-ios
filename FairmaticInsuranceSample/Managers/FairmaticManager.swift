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
    
    private let driverAttributes = DriverAttributes(name: "John Doe",
                                                    email: "johndoe@company.com",
                                                    phoneNumber: "+11234567890")
    
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
        let trackingId = "P2-\(Date.currentMillis())"
        log.debug("Starting period 2")
        Fairmatic.startDriveWithPeriod2(trackingId, completionHandler: completion)
    }
    
    func startPeriod3(completion: @escaping FairmaticCompletionHandler) {
        log.debug("Starting period 3")
        let trackingId = "P3-\(Date.currentMillis())"
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
        let configuration = Configuration(sdkKey: sdkKey,
                                          driverId: driverId,
                                          driverAttributes: driverAttributes)
        Fairmatic.setupWith(configuration: configuration,
                            delegate: self) { (success, error) in
            let error: NSError? = error as NSError?
            if var error { // SDK initialization failed
                log.error("SDK initialization failed due to error: \(error.localizedDescription) at attempt \(trialNumber)/\(totalRetryCount)")
                if (trialNumber < totalRetryCount) {
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
}

// MARK: Fairmatic Delegate

extension FairmaticManager: FairmaticDelegate {
    func processStart(ofDrive startInfo: DriveStartInfo) {
        log.debug("Fairmatic SDK started for drive with tracking id \(startInfo.trackingId ?? "nil")")
    }
    
    func processResume(ofDrive resumeInfo: DriveResumeInfo) {
        log.debug("Fairmatic SDK resumed for drive with tracking id \(resumeInfo.trackingId ?? "nil")")
    }
    
    func processAnalysis(ofDrive analyzedDriveInfo: AnalyzedDriveInfo) {
        log.debug("Fairmatic SDK analyzed drive with tracking id \(analyzedDriveInfo.trackingId ?? "nil")")
    }
    
    func processPotentialAccidentDetected(_ accidentInfo: AccidentInfo) {
        log.debug("Fairmatic SDK detected potential accident with tracking id \(accidentInfo.trackingId ?? "nil")")
    }
    
    func processAccidentDetected(_ accidentInfo: AccidentInfo) {
        log.debug("Fairmatic SDK detected accident with tracking id \(accidentInfo.trackingId ?? "nil")")
    }
    
    func processEnd(ofDrive estimatedDriveInfo: EstimatedDriveInfo) {
        log.debug("Fairmatic SDK ended drive with tracking id \(estimatedDriveInfo.trackingId ?? "nil")")
    }
    
    func settingsChanged(_ settings: Settings) {
        log.debug("Settings changed from FMSDK, and \(settings.errors.count) errors were found!")
        
        settings.errors.forEach {
            print("Error from Fairmatic SDK: \($0.errorType)")
        }
    }
}
