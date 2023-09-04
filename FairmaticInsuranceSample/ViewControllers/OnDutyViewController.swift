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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "On Duty"
        [acceptNewRideRequestButton, pickupPassengerButton, cancelRequestButton, dropPassengerButton, goOffDutyButton].forEach {
            $0?.startAnimatingPressActions()
            $0?.layer.cornerRadius = 8
            
        }
        
        refreshUI()
    }
    
    //MARK: User Actions
    
    @IBAction func acceptNewRideRequestButtonTapped(_ sender: Any) {
        TripManager.shared.acceptNewPassengerRequest { success, error in
            if success {
                self.refreshUI()
            } else {
                log.error("Failed to accept new passenger request: \(error!.localizedDescription)")
            }
        }
    }
    
    @IBAction func pickupPassengerButtonTapped(_ sender: Any) {
        TripManager.shared.pickupPassenger { success, error in
            if success {
                self.refreshUI()
            } else {
                log.error("Failed to pickup passenger: \(error!.localizedDescription)")
            }
        }
    }
    
    @IBAction func canceRequestButtonTapped(_ sender: Any) {
        TripManager.shared.cancelRequest { success, error in
            if success {
                self.refreshUI()
            } else {
                log.error("Failed to cancel request: \(error!.localizedDescription)")
            }
        }
    }
    
    @IBAction func dropPassengerButtonTapped(_ sender: Any) {
        TripManager.shared.dropPassenger { success, error in
            if success {
                self.refreshUI()
            } else {
                log.error("Failed to drop passenger: \(error!.localizedDescription)")
            }
        }
    }
    
    @IBAction func goOffDutyButtonTapped(_ sender: Any) {
        TripManager.shared.goOffDuty { success, error in
            if success {
                self.delegate?.driverDidRequestToGoOffDuty()
            } else {
                log.error("Failed to go off duty: \(error!.localizedDescription)")
            }
        }
    }
}

private extension OnDutyViewController {
    private func currentInsurancePeriod() -> Int {
        var insurancePeriod = 1
        let state: State = TripManager.shared.state
        if (state.passengerInCar) {
            insurancePeriod = 3
        } else if (state.passenegerWaitingForPickup) {
            insurancePeriod = 2
        }
        
        return insurancePeriod
    }
    
    private func refreshUI() {
        log.debug("Refreshing UI")
        
        let insurancePeriod = currentInsurancePeriod()
        let state: State = TripManager.shared.state

        // Update text
        self.insurancePeriodLabel.text = "Insurance Period: \(insurancePeriod)"
        self.passengerInCarLabel.text = "Passenger In Car: \(state.passengerInCar)"
        self.passengerWaitingLabel.text = "Passengers awaiting pickup:" +
        " \(state.passenegerWaitingForPickup)"

        // Enable/Disable buttons
        self.acceptNewRideRequestButton.isEnabled = !state.passenegerWaitingForPickup && !state.passengerInCar
        self.dropPassengerButton.isEnabled = (state.passengerInCar)
        self.pickupPassengerButton.isEnabled = (state.passenegerWaitingForPickup && !state.passengerInCar)
        self.cancelRequestButton.isEnabled = (state.passenegerWaitingForPickup && !state.passengerInCar)
        self.goOffDutyButton.isEnabled = !state.passengerInCar &&
            !state.passenegerWaitingForPickup
    }
}

extension UIButton {
    open override var isEnabled: Bool{
        didSet {
            alpha = isEnabled ? 1.0 : 0.5
        }
    }
}
