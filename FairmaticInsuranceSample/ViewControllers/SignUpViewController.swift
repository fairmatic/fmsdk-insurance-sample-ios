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

    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var signupButton: UIButton!
    
    weak var delegate: SignUpViewControllerDelegate?
    
    private let userDefaultsManager = FairmaticInsuranceUserDefaults.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        
        signupButton.layer.cornerRadius = 8.0

        emailTextField.keyboardType = .emailAddress
        emailTextField.becomeFirstResponder()
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(Self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @IBAction func signupButtonTapped(_ sender: Any) {
        emailTextField.resignFirstResponder()
        let driverId = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let driverId = driverId, !driverId.isEmpty, Fairmatic.isValidInputParameter(driverId) else {
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
        let alertController = UIAlertController(title: "Invalid driver email", message: "Please enter a valid email id for the driver", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}
