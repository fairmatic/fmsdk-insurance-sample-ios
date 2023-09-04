//
//  TripManager.swift
//  FairmaticInsuranceSample
//
//  Created by Sagar Dagdu on 31/08/23.
//

import Foundation

final class State {
    /// The driver is on duty and is available to accept new ride requests
    var isDriverOnDuty: Bool
    
    /// Is a passeger waiting for pickup
    var passenegerWaitingForPickup: Bool
    
    /// Is a passenger in car currently
    var passengerInCar: Bool
    
    /// The tracking ID of the trip
    var trackingId: String?

    init(isDriverOnDuty: Bool,
         passenegerWaitingForPickup: Bool,
         passengerInCar: Bool,
         trackingId: String?) {
        self.isDriverOnDuty = isDriverOnDuty
        self.passenegerWaitingForPickup = passenegerWaitingForPickup
        self.passengerInCar = passengerInCar
        self.trackingId = trackingId
    }

    init(state: State) {
        self.isDriverOnDuty = state.isDriverOnDuty
        self.passenegerWaitingForPickup = state.passenegerWaitingForPickup
        self.passengerInCar = state.passengerInCar
        self.trackingId = state.trackingId
    }
}

final class TripManager {
    
    // MARK: Properties
    
    private let fairmaticUserDefaults = FairmaticInsuranceUserDefaults.shared
    
    private let fairmaticManager = FairmaticManager.shared
    
    static let shared = TripManager()
    
    private init() {
        self.state = State(isDriverOnDuty: fairmaticUserDefaults.isDriverOnDuty,
                      passenegerWaitingForPickup: fairmaticUserDefaults.isPassengerWaitingForPickup,
                      passengerInCar: fairmaticUserDefaults.isPassengerInCar,
                      trackingId: fairmaticUserDefaults.trackingId)
    }
    
    /// The state of the trip manager
    private var state: State
    
    // MARK: Functions
    
    func goOnDuty(completion: @escaping FairmaticCompletionHandler) {
        log.debug("Going on duty")
        
       synchronized(self) {
            state.isDriverOnDuty = true
            fairmaticUserDefaults.isDriverOnDuty = true
            setupOrTeardownPermissionManager()
            fairmaticManager.updateInsurancePeriodsBasedOnApplicationState(completion: completion)
        }
    }
    
    func goOffDuty(completion: @escaping FairmaticCompletionHandler) {
        log.debug("Going off duty")
        synchronized(self) {
            state.isDriverOnDuty = false
            fairmaticUserDefaults.isDriverOnDuty = false
            setupOrTeardownPermissionManager()
            fairmaticManager.updateInsurancePeriodsBasedOnApplicationState(completion: completion)
        }
    }
    
    func acceptNewPassengerRequest(completion: @escaping FairmaticCompletionHandler) {
        log.debug("Accepting new passenger request")
        synchronized(self) {
            state.passenegerWaitingForPickup = true
            fairmaticUserDefaults.isPassengerWaitingForPickup = true
            fairmaticManager.updateInsurancePeriodsBasedOnApplicationState(completion: completion)
        }
    }
    
    func pickupPassenger(completion: @escaping FairmaticCompletionHandler) {
        log.debug("Picking up passenger")
        synchronized(self) {
            state.passengerInCar = true
            state.passenegerWaitingForPickup = false
            fairmaticUserDefaults.isPassengerInCar = true
            fairmaticUserDefaults.isPassengerWaitingForPickup = false
            fairmaticManager.updateInsurancePeriodsBasedOnApplicationState(completion: completion)
        }
    }
    
    func cancelRequest(completion: @escaping FairmaticCompletionHandler) {
        log.debug("Cancelling request")
        synchronized(self) {
            state.passenegerWaitingForPickup = false
            fairmaticUserDefaults.isPassengerWaitingForPickup = false
            fairmaticManager.updateInsurancePeriodsBasedOnApplicationState(completion: completion)
        }
    }
    
    func dropPassenger(completion: @escaping FairmaticCompletionHandler) {
        log.debug("Dropping passenger")
        synchronized(self) {
            state.passengerInCar = false
            fairmaticUserDefaults.isPassengerInCar = false
            fairmaticManager.updateInsurancePeriodsBasedOnApplicationState(completion: completion)
        }
    }
    
    func getState() -> State {
        var state: State? = nil
        synchronized(self) {
            state = State(state: self.state)
        }
        
        return state!
    }
}

extension TripManager {
    private func setupOrTeardownPermissionManager() {
        if (state.isDriverOnDuty) {
            log.debug("Driver is on duty, setting up permission manager")
            PermissionManager.setup()
        } else {
            log.debug("Driver is off duty, tearing down permission manager")
            PermissionManager.teardown()
        }
    }
}
