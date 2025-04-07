//
//  SignUpViewController.swift
//  FairmaticInsuranceSample
//
//  Created by Sagar Dagdu on 31/08/23.
//

import UIKit
import FairmaticSDK

protocol SignUpViewControllerDelegate: AnyObject {
    func signupCompleted()
}

extension SignUpViewController {
    static func instantiateFromStoryboard() -> Self {
        UIStoryboard.main.instantiateViewController(withIdentifier: "SignUpViewController") as! Self
    }
}

final class SignUpViewController: UIViewController {

    @IBOutlet private weak var driverIdTextField: UITextField!
    @IBOutlet private weak var signupButton: UIButton!
    
    weak var delegate: SignUpViewControllerDelegate?
    
    private let userDefaultsManager = FairmaticInsuranceUserDefaults.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        
        signupButton.layer.cornerRadius = 8.0

        driverIdTextField.keyboardType = .emailAddress
        driverIdTextField.becomeFirstResponder()
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(Self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func signupButtonTapped(_ sender: Any) {
        driverIdTextField.resignFirstResponder()
        let driverId = driverIdTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let driverId = driverId, !driverId.isEmpty else {
            showInvalidDriverAlert()
            return
        }
        
        userDefaultsManager.driverId = driverId
        delegate?.signupCompleted()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

private extension SignUpViewController {
    func showInvalidDriverAlert() {
        let alertController = UIAlertController(title: "Invalid driver ID", message: "Please enter a valid driver ID.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}
