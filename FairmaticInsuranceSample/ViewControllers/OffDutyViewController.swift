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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Off Duty"
        goOnDutyButton.startAnimatingPressActions()
        goOnDutyButton.layer.cornerRadius = 8.0
    }
    
    @IBAction func goOnDutyButtonTapped(_ sender: Any) {
        TripManager.shared.goOnDuty { success, error in
            if success {
                self.delegate?.driverDidRequestToGoOnDuty()
            } else {
                log.error("Error in going on duty: \(String(describing: error))")
            }
        }
    }
}
