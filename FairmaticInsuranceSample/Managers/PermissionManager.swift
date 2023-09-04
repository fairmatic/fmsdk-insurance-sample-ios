//
//  PermissionManager.swift
//  FairmaticInsuranceSample
//
//  Created by Sagar Dagdu on 01/09/23.
//

import Foundation

import UIKit
import CoreLocation

class PermissionManager: NSObject, CLLocationManagerDelegate {
    static var _sharedInstance: PermissionManager?
    
    public static func setup() {
        synchronized(self) {
            self._sharedInstance = PermissionManager()
        }
    }

    public static func teardown() {
        synchronized(self) {
            self._sharedInstance = nil
        }
    }

    private var _locationManager: CLLocationManager?
    private var _locationPermissionAlert: UIAlertController?
    private var _alertWindow: UIWindow?
    
    private override init() {
        super.init()
        _locationManager = CLLocationManager()
        _locationManager?.delegate = self
    }

    internal func locationManager(_ manager: CLLocationManager,
                                  didChangeAuthorization status: CLAuthorizationStatus) {
        switch (status) {
        case CLAuthorizationStatus.restricted: fallthrough
        case CLAuthorizationStatus.denied: fallthrough
        case CLAuthorizationStatus.authorizedWhenInUse:
            // Display location permisison view controller
            displayLocationPermissionErrorViewNotVisible()
        // Follow through to ask for permission
        case CLAuthorizationStatus.notDetermined:
            // Request for location, specifically for iOS8
            if (_locationManager != nil &&
                _locationManager!.responds(
                    to: #selector(CLLocationManager.requestAlwaysAuthorization))) {
                _locationManager!.requestAlwaysAuthorization()
            }
            break
        case CLAuthorizationStatus.authorizedAlways:
            // Remove location permission view controller
            hideLocationPermissionErrorViewIfVisible()
            break
        @unknown default:
            fatalError("Unknown location permission state")
        }
    }

    func displayLocationPermissionErrorViewNotVisible() {
        guard _locationPermissionAlert == nil else { return }
        
        let errorMessage: String = "Please provide \"Always Allow\" location" +
        " permission with precise location enabled to get insurance benefits"
        
        _locationPermissionAlert = UIAlertController(title: "Location Permission Denied",
                                                     message: errorMessage,
                                                     preferredStyle: .alert)
        
        _locationPermissionAlert?.addAction(UIAlertAction(title: "Open Settings",
                                                          style: .default,
                                                          handler: { [weak self] _ in
            // Show application settings
            
            if (self != nil && self?._locationPermissionAlert != nil) {
                self?.showAlert(alert: (self?._locationPermissionAlert)!)
            }
        }))
        
        self.showAlert(alert: _locationPermissionAlert!)
    }

    func showAlert(alert: UIAlertController) {
        if (_alertWindow == nil) {
            _alertWindow = UIWindow.init(frame: UIScreen.main.bounds)
            _alertWindow!.rootViewController = UIViewController()
            _alertWindow!.windowLevel = UIWindow.Level.alert + 1;
            _alertWindow!.makeKeyAndVisible();
        }
        _alertWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        _locationPermissionAlert = alert;
    }

    func hideLocationPermissionErrorViewIfVisible() {
        if (_locationPermissionAlert == nil) {
            return
        }
        _locationPermissionAlert?.dismiss(animated: true, completion: {
            [weak self] in
            self?._alertWindow = nil
        })
        
        _locationPermissionAlert = nil;
    }
}
