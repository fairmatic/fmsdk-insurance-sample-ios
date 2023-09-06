//
//  OffDutyViewController.swift
//  FairmaticInsuranceSample
//
//  Created by Sagar Dagdu on 31/08/23.
//

import UIKit

protocol OffDutyViewControllerDelegate: AnyObject {
    func driverDidRequestToGoOnDuty()
}

extension OffDutyViewController {
    static func instantiateFromStoryboard() -> Self {
        UIStoryboard.main.instantiateViewController(withIdentifier: "OffDutyViewController") as! Self
    }
}

final class OffDutyViewController: UIViewController {

    @IBOutlet private weak var goOnDutyButton: UIButton!
    
    weak var delegate: OffDutyViewControllerDelegate?
    
    private let fairmaticUserDefaults = FairmaticInsuranceUserDefaults.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Off Duty"
        goOnDutyButton.startAnimatingPressActions()
        goOnDutyButton.layer.cornerRadius = 8.0
    }
    
    @IBAction func goOnDutyButtonTapped(_ sender: Any) {
        log.debug("Going on duty")
        
        // Set the driver onduty user default to true
        fairmaticUserDefaults.isDriverOnDuty = true
        
        FairmaticManager.shared.startPeriod1 { success, error in
            if success {
                log.debug("Started driver with period 1")
            } else {
                log.error("Error in going on duty: \(error!.localizedDescription)")
            }
        }
        
        self.delegate?.driverDidRequestToGoOnDuty()
    }
}
