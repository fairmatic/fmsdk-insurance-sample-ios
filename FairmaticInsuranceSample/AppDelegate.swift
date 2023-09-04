//
//  AppDelegate.swift
//  FairmaticInsuranceSample
//
//  Created by Sagar Dagdu on 29/08/23.
//

import UIKit
import MBProgressHUD

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    /// The main window
    var window: UIWindow?
    
    /// The root navigation controller that contains view controllers
    var rootNavigationController: UINavigationController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        reloadApplication()
        return true
    }
}

private extension AppDelegate {
    func reloadApplication() {
        log.debug("Reloading application")
        guard let driverId = FairmaticInsuranceUserDefaults.shared.driverId else {
            log.debug("Driver id not found, loading signup view controller")
            TripManager.shared.goOffDuty { _, _ in }
            loadSignupViewController()
            return
        }
        
        if (window?.rootViewController == nil) {
            let launchScreen: UIViewController = UIStoryboard(
                name: "LaunchScreen",
                bundle: Bundle.main
            ).instantiateInitialViewController()!
            window?.rootViewController = launchScreen
        }
        
        showLoader()
        
        log.debug("Initializing SDK for driver id: \(driverId)")
        FairmaticManager.shared.initializeSDKForDriverId(driverId: driverId) {
            log.debug("SDK initialized successfully")
            self.hideLoader()
            self.loadViewControllerAccordingToDuty()
        } failureHandler: { nsError in
            self.hideLoader()
            log.error("Failed to initialize SDK: \(nsError!.localizedDescription)")
            let alert: UIAlertController =
                UIAlertController.init(title: "SDK Initialization Failed",
                                       message: nsError!.localizedDescription,
                                       preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Retry",
                                          style: .default,
                                          handler: { _ in
                    self.reloadApplication()
            }))
            
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func loadViewControllerAccordingToDuty() {
        if FairmaticInsuranceUserDefaults.shared.isDriverOnDuty {
            loadOnDutyViewController()
        } else {
            loadOffDutyViewController()
        }
    }
    
    func loadOffDutyViewController() {
        log.debug("Loading off duty view controller")
        let offDutyViewController = OffDutyViewController.instantiateFromStoryboard()
        offDutyViewController.delegate = self
        showInNavigationController(viewController: offDutyViewController)
    }
    
    func loadOnDutyViewController() {
        log.debug("Loading on duty view controller")
        let onDutyViewController = OnDutyViewController.instantiateFromStoryboard()
        onDutyViewController.delegate = self
        showInNavigationController(viewController: onDutyViewController)
    }
    
    func loadSignupViewController() {
        log.debug("Loading signup view controller")
        let signupViewController = SignUpViewController.instantiateFromStoryboard()
        signupViewController.delegate = self
        showInNavigationController(viewController: signupViewController)
    }
    
    func showLoader() {
        MBProgressHUD.showAdded(to: window!, animated: true)
    }
    
    func hideLoader() {
        MBProgressHUD.hide(for: window!, animated: true)
    }
    
    func showInNavigationController(viewController: UIViewController) {
        guard let rootNavigationController else {
            rootNavigationController = UINavigationController(rootViewController: viewController)
            window?.rootViewController = rootNavigationController
            return
        }
        
        rootNavigationController.setViewControllers([viewController], animated: true)
    }
}

extension AppDelegate: OffDutyViewControllerDelegate, OnDutyViewControllerDelegate, SignUpViewControllerDelegate {
    func signupCompleted() {
        log.debug("Signup completed")
        reloadApplication()
    }
    
    func driverDidRequestToGoOnDuty() {
        log.debug("Driver did request to go on duty")
        loadViewControllerAccordingToDuty()
    }
    
    func driverDidRequestToGoOffDuty() {
        log.debug("Driver did request to go off duty")
        loadViewControllerAccordingToDuty()
    }
}
