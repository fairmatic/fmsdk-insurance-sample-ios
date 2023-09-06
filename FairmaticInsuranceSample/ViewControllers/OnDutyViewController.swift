//
//  OnDutyViewController.swift
//  FairmaticInsuranceSample
//
//  Created by Sagar Dagdu on 31/08/23.
//

import UIKit

extension OnDutyViewController {
    static func instantiateFromStoryboard() -> Self {
        UIStoryboard.main.instantiateViewController(withIdentifier: "OnDutyViewController") as! Self
    }
}

protocol OnDutyViewControllerDelegate: AnyObject {
    func driverDidRequestToGoOffDuty()
}

final class OnDutyViewController: UIViewController {

    //MARK: IBOutlets
    
    @IBOutlet private weak var passengerInCarLabel: UILabel!
    @IBOutlet private weak var passengerWaitingLabel: UILabel!
    @IBOutlet private weak var insurancePeriodLabel: UILabel!
    @IBOutlet private weak var acceptNewRideRequestButton: UIButton!
    @IBOutlet private weak var pickupPassengerButton: UIButton!
    @IBOutlet private weak var cancelRequestButton: UIButton!
    @IBOutlet private weak var dropPassengerButton: UIButton!
    @IBOutlet private weak var goOffDutyButton: UIButton!
    
    weak var delegate: OnDutyViewControllerDelegate?
    
    private let fairmaticUserDefaults = FairmaticInsuranceUserDefaults.shared
    
    private let fairmaticManager = FairmaticManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "On Duty"
        [acceptNewRideRequestButton, pickupPassengerButton, cancelRequestButton, dropPassengerButton, goOffDutyButton].forEach {
            $0?.startAnimatingPressActions()
            $0?.layer.cornerRadius = 8
            $0?.setTitleColor(.white, for: .disabled)
        }
        
        refreshUI()
    }
    
    //MARK: User Actions
    
    @IBAction func acceptNewRideRequestButtonTapped(_ sender: Any) {
        log.debug("Accepting new passenger request")
        
        fairmaticUserDefaults.isPassengerWaitingForPickup = true
        fairmaticManager.startPeriod2 { [weak self] success, error in
            if success {
                self?.refreshUI()
            } else {
                log.error("Failed to start period 2 when accepting new passenger request, error: \(error!.localizedDescription)")
            }
        }
    }
    
    @IBAction func pickupPassengerButtonTapped(_ sender: Any) {
        log.debug("Picking up passenger")
        
        fairmaticUserDefaults.isPassengerInCar = true
        fairmaticUserDefaults.isPassengerWaitingForPickup = false
        
        fairmaticManager.startPeriod3 { [weak self] success, error in
            if success {
                self?.refreshUI()
            } else {
                log.error("Failed to start period 3 when picking up passenger, error: \(error!.localizedDescription)")
            }
        }
    }
    
    @IBAction func canceRequestButtonTapped(_ sender: Any) {
        log.debug("Cancelling request")

        fairmaticUserDefaults.isPassengerWaitingForPickup = false
        
        fairmaticManager.startPeriod1 { [weak self] success, error in
            if success {
                self?.refreshUI()
            } else {
                log.error("Failed to start period 1 when cancelling pickup request, error: \(error!.localizedDescription)")
            }
        }
    }
    
    @IBAction func dropPassengerButtonTapped(_ sender: Any) {
        log.debug("Dropping passenger")
        
        fairmaticUserDefaults.isPassengerInCar = false
        
        fairmaticManager.startPeriod1 { [weak self] success, error in
            if success {
                self?.refreshUI()
            } else {
                log.error("Failed to start period 1 when dropping passenger, error: \(error!.localizedDescription)")
            }
        }
    }
    
    @IBAction func goOffDutyButtonTapped(_ sender: Any) {
        log.debug("Going off duty")

        fairmaticUserDefaults.isDriverOnDuty = false
        fairmaticManager.stopPeriod { success, error in
            if success {
                log.debug("Stopped period")
            } else {
                log.error("Failed to stop period when driver going off duty, error: \(error!.localizedDescription)")
            }
        }
        
        self.delegate?.driverDidRequestToGoOffDuty()
    }
}

private extension OnDutyViewController {
    private func currentInsurancePeriod() -> Int {
        var insurancePeriod = 1
        if (fairmaticUserDefaults.isPassengerInCar) {
            insurancePeriod = 3
        } else if (fairmaticUserDefaults.isPassengerWaitingForPickup) {
            insurancePeriod = 2
        }
        
        return insurancePeriod
    }

    private func refreshUI() {
        let insurancePeriod = currentInsurancePeriod()
        switch insurancePeriod {
        case 1:
            refreshUIForPeriod1()
        case 2:
            refreshUIForPeriod2()
        case 3:
            refreshUIForPeriod3()
        default:
            break
        }

        updateButtonStatesAccordingToEnabled()
    }
    
    private func refreshUIForPeriod1() {
        log.debug("Refreshing UI for Period 1")
        
        // Update text
        self.insurancePeriodLabel.text = "Insurance Period: 1"
        self.passengerInCarLabel.text = "Passenger In Car: false"
        self.passengerWaitingLabel.text = "Passengers awaiting pickup: false"

        // Enable/Disable buttons
        self.acceptNewRideRequestButton.isEnabled = true
        self.dropPassengerButton.isEnabled = false
        self.pickupPassengerButton.isEnabled = false
        self.cancelRequestButton.isEnabled = false
        self.goOffDutyButton.isEnabled = true
    }
    
    private func refreshUIForPeriod2() {
        log.debug("Refreshing UI for Period 2")
        
        // Update text
        self.insurancePeriodLabel.text = "Insurance Period: 2"
        self.passengerInCarLabel.text = "Passenger In Car: false"
        self.passengerWaitingLabel.text = "Passengers awaiting pickup: true"

        // Enable/Disable buttons
        self.acceptNewRideRequestButton.isEnabled = false
        self.dropPassengerButton.isEnabled = false
        self.pickupPassengerButton.isEnabled = true
        self.cancelRequestButton.isEnabled = true
        self.goOffDutyButton.isEnabled = false
    }
    
    private func refreshUIForPeriod3() {
        log.debug("Refreshing UI for Period 3")
        
        // Update text
        self.insurancePeriodLabel.text = "Insurance Period: 3"
        self.passengerInCarLabel.text = "Passenger In Car: true"
        self.passengerWaitingLabel.text = "Passengers awaiting pickup: false"

        // Enable/Disable buttons
        self.acceptNewRideRequestButton.isEnabled = false
        self.dropPassengerButton.isEnabled = true
        self.pickupPassengerButton.isEnabled = false
        self.cancelRequestButton.isEnabled = false
        self.goOffDutyButton.isEnabled = false
    }
    
    private func updateButtonStatesAccordingToEnabled() {
        [acceptNewRideRequestButton,
         pickupPassengerButton,
         cancelRequestButton,
         dropPassengerButton,
         goOffDutyButton
        ].forEach {
            $0.alpha = $0.isEnabled ? 1.0 : 0.5
        }
    }
}
