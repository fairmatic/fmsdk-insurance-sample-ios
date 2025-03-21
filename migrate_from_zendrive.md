# Migrating from Zendrive SDK to Fairmatic SDK

If you are using Zendrive SDK, this guide will help you with the quick steps you need to follow to migrate to 3.x version of the Fairmatic SDK.

> Copy the Fairmatic SDK key, available in the [advanced tab](https://app.fairmatic.com/app/settings/advanced) of the settings screen on the Fairmatic dashboard. Use the Fairmatic SDK key for Fairmatic SDK. Note that the Fairmatic SDK key **can NOT** be used with the Zendrive SDK or vice versa.


## Latest SDK installation

In your Podfile, remove the Zendrive dependency and add the Fairmatic SDK dependency using:
```ruby
pod 'FairmaticSDK', :git => 'https://github.com/fairmatic/fairmatic-cocoapods', :tag => '3.0.0'
```
and run the pod install command

## Changes to the project settings

### Changes to Background Modes

The `3.0.0` uses background fetch in addition to background location to ensure the smooth and timely uploads of trips.
Allow background background fetch for your app:
On the project screen, click Capabilities → Turn Background Modes on → Select Background Fetch

## Changes to Permission-related keys in `Info.plist`

In addition to location and motion related keys which were needed in the previous versions of the SDK, this version also needs bluetooth usage related keys.

```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Bluetooth</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>Bluetooth</string>
```

> [!NOTE] 
> Even though we won't actually use Bluetooth features, Apple requires this message whenever Bluetooth code is present in an app. This is just a technical requirement.

### Background task ID configuration

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

## Code changes

### `import` statement changes

Replace all the imports of Zendrive SDK to Fairmatic SDK i.e. `import ZendriveSDK` to `import FairmaticSDK`

### Change the `DriverAttributes` and `Configuration` initialization

To initialize the `Configuration`, you need to pass an instance of `DriverAttributes`. Hence, first initialize the `DriverAttributes` in the following way:

```swift
private let driverAttributes = DriverAttributes(
    firstName: "John",
    lastName: "Doe",
    email: "johndoe@company.com",
    phoneNumber: "+11234567890"
)
```
and the initialize the configuration object:
```swift
let configuration = Configuration(sdkKey: "fairmatic_sdk_key",
                                  driverId: driverId,
                                  driverAttributes: driverAttributes)
```
> [!NOTE] 
> Make sure you pass the Fairmatic SDK key when creating the `Configuration` object. If your backend systems provide the SDK keys, pass the correct SDK key to the application based on the application version. The Zendrive SDK key should be used to set up Zendrive SDK and the Fairmatic SDK key should be used to set up Fairmatic SDK.

and then finally initialize the SDK
```swift
Fairmatic.setupWith(configuration: configuration) { (success, error) in
    // Handle success or error here
}
```

### Insurance period API changes

Replace all the `Zendrive.startPeriodX()` API calls with `Fairmatic.startPeriodX()`. Also, the `startPeriod1()` API accepts a `trackingId` string on the Fairmatic SDK to stay consistent with the other insurance period APIs.

### Removal of the `Zendrive.isValidInputParameter()` method.

You no longer need to check your input strings using this method, as all the individual APIs of the SDK validate the strings and return appropriate errors if the strings are invalid.