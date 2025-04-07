# Integrate the Fairmatic iOS SDK in your app

## Prerequisites for the SDK

- The SDK supports iOS 13 or above. Your app should target iOS 13 or above to use the SDK.
- You should have the latest stable version of Xcode installed.
- [Sign in](https://app.fairmatic.com/settings/advanced) to the Fairmatic dashboard to access your Fairmatic SDK Key.

## SDK Installation

### Cocoapods

In your Podfile, add the following line
```ruby
pod 'FairmaticSDK', :git => 'https://github.com/fairmatic/fairmatic-cocoapods', :tag => '3.0.0'
```
and run the `pod install` command

### Swift Package Manager

- Open your project in Xcode 16.0 or above
- Go to File > Swift Packages > Add Package Dependency...
- In the field Enter package repository URL, enter https://github.com/fairmatic/fairmatic-sdk-spm
- Pick the latest version (3.x) and click Next.
- Click Finish
- Add the `-ObjC` flag to the Other Linker Flags section of your target's build settings.

## Adjusting project settings

### Background Modes

Allow background location updates and background fetch for your app:
On the project screen, click Capabilities → Turn Background Modes on → Select Location updates and Background Fetch

### Permission-related keys in `Info.plist`

If your app does not already have them, please include the following keys in your app's `Info.plist`:

```xml
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need background location permission to provide you with
driving analytics</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need background location permission to provide you with
driving analytics</string>
<key>NSMotionUsageDescription</key>
<string>We use activity to detect your trips faster and more accurately.
This also reduces the amount of battery we use.</string>
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Bluetooth</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>Bluetooth</string>
```

> [!NOTE] 
> Even though we won't actually use Bluetooth features, Apple requires this message whenever Bluetooth code is present in an app. This is just a technical requirement.


### Background task ID

For the Fairmatic SDK to be more accurate in uploading all trip data, it needs to have [background fetch capability](https://developer.apple.com/documentation/uikit/using-background-tasks-to-update-your-app) and a background task id declared in your Info.plist file. You must add the following line in `Info.plist` file:

```xml
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
	<string>com.fairmatic.sdk.bgrefreshtask</string>
</array>
```

In the case you already have a background refresh task, as iOS allows only one scheduled background fetch task, you will need to reuse your existing `BGAppRefreshTask` to call the following function:

```swift
Fairmatic.logSDKHealth(.backgroundProcessing) { _ in
    // task.setTaskCompleted(success: success)
}
```

In this case, don’t add the new `BGTaskSchedulerPermittedIdentifiers` to your Info.plist.

## Setup the Fairmatic SDK in code

The following code snippet shows how to initialize the SDK. You will need the SDK key and the driver details.

```swift
// 1. Import the Fairmatic SDK module
import FairmaticSDK

// 2. Driver attributes creation
let driverAttributes = DriverAttributes(firstName: "John",
                                        lastName: "Doe",
                                        email: "john_doe@company.com",
                                        phoneNumber: "1234567890")

// 3. Creation of the config object using SDK key, driverId, and the above driver attributes.
let config = Configuration(sdkKey: "your_sdk_key_here",
                           driverId: "alphanumeric_driver_id",
                           driverAttributes: driverAttributes)

// 4. Setup the SDK with the config object, check for success.
Fairmatic.setupWith(
    configuration: config
) { [weak self] success, error in
    if success {
        print("Fairmatic SDK setup successfully!")
    } else {
        print("Failed to init the Fairmatic SDK, error: \(error)")
    }
}
```

> [!IMPORTANT]
> Please put this code in your `AppDelegate`’s `didFinishLaunchingWithOptions()` method if a driver is already available in your app. This code should also be present in the flow when your driver logs in successfully into the app. The SDK’s `Fairmatic.setup()` API should be called at every app launch with proper configuration. Failing to do so will result in errors in the trip APIs.

## Call the insurance APIs

### Insurance period 1
Start insurance period 1 when the driver starts the day and is waiting for a request. The tracking ID is a key that is used to uniquely identify the insurance trip.

```swift
Fairmatic.startDriveWithPeriod1("some_unique_string_p1") { [weak self] success, error in
    if success {
        print("Started trip \(trackingId) with period 1")        
    } else if let error {
        print("Failed to start trip with period 1: \(error)")
    }
}
```

### Insurance period 2
Start insurance period 2 when the driver accepts the passenger's or the company's request.

```swift
Fairmatic.startDriveWithPeriod2("some_unique_string_p2") { [weak self] success, error in
    if success {
        print("Started trip \(trackingId) with period 2")        
    } else if let error {
        print("Failed to start trip with period 2: \(error)")
    }
}
```

### Insurance period 3
Start insurance period 3 when the passenger/goods board the vehicle. In case of multiple passengers, the SDK needs to stay in insurance period 3.

```swift
Fairmatic.startDriveWithPeriod3("some_unique_string_p3") { [weak self] success, error in
    if success {
        print("Started trip \(trackingId) with period 3")        
    } else if let error {
        print("Failed to start trip with period 3: \(error)")
    }
}
```
### Stopping the insurance period
Stop the insurance period when the driver ends the work day. Call stop period when the driver is no longer looking for a request.

```swift
Fairmatic.stopPeriod { [weak self] success, error in
    if success {
        print("Stopped period drive")
    } else if let error {
        print("Failed to stop period drive: \(error)")
    }
}
```

## Fairmatic SDK settings

Ensure you check for any errors and take appropriate actions in your app to resolve them, ensuring the Fairmatic SDK operates smoothly. Use the following code snippet to perform this check:

```swift
Fairmatic.getSettings { settings in
    guard let settings = settings else {
        print("Failed to get settings, check whether the SDK is setup")
        return
    }
    
    // Check the errors and take actions in your 
    // app to resolve those errors
    for settingsError in settings.errors {
        switch settingsError.errorType {
        case .locationServiceOff:
            print("Location services off")
        case .locationPermissionNotAuthorized:
            print("Location permission not authorized. Make sure you allow always access to location")
        case .locationAccuracyAuthorizationReduced:
            print("Location accuracy reduced")
        case .activityPermissionNotAuthorized:
            print("Motion and fitness permission not authorized")
        @unknown default:
            print("-")
        }
    }
}
```

## Disable SDK [Optional step]
Call teardown API when the driver is no longer working with the application and logs out. This will completely disable the SDK on the application.

```swift
Fairmatic.teardown { [weak self] in
    print("Fairmatic SDK torn down")
}
```
