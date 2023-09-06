//
//  UserDefaultsManager.swift
//  FairmaticInsuranceSample
//
//  Created by Sagar Dagdu on 31/08/23.
//

import Foundation

final class FairmaticInsuranceUserDefaults {
    private let userDefaults = UserDefaults.standard
    
    static let shared = FairmaticInsuranceUserDefaults()
    
    private init() {}
    
    private struct UserDefaultsKeys {
        static let driverId = "driverId"
        static let isDriverOnDuty = "isDriverOnDuty"
        static let passengerInCar = "passengerInCar"
        static let passengerWaitingForPickup = "passengerWaitingForPickup"
        
        private init() {}
    }
    
    var driverId: String? {
        get {
            userDefaults.string(forKey: UserDefaultsKeys.driverId)
        }
        
        set {
            userDefaults.set(newValue, forKey: UserDefaultsKeys.driverId)
        }
    }
    
    var isDriverOnDuty: Bool {
        get {
            userDefaults.bool(forKey: UserDefaultsKeys.isDriverOnDuty)
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultsKeys.isDriverOnDuty)
        }
    }
    
    var isPassengerInCar: Bool {
        get {
            userDefaults.bool(forKey: UserDefaultsKeys.passengerInCar)
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultsKeys.passengerInCar)
        }
    }
    
    var isPassengerWaitingForPickup: Bool {
        get {
            userDefaults.bool(forKey: UserDefaultsKeys.passengerWaitingForPickup)
        }
        set {
            userDefaults.set(newValue, forKey: UserDefaultsKeys.passengerWaitingForPickup)
        }
    }
}
