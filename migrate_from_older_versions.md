# Migrating from previous versions of Fairmatic SDK

If you are already using Fairmatic SDK 1.x or 2.x, this guide will help you with the quick steps you need to follow to migrate to 3.x version of the SDK.

## Latest SDK installation

In your Podfile, change the version to `3.0.0`:
```ruby
pod 'FairmaticSDK', :git => 'https://github.com/fairmatic/fairmatic-cocoapods', :tag => '3.0.0'
```
and run the pod install command

## Changes to the project settings

### Changes to Background Modes

The `3.0.0` uses background fetch in addition to background location to ensure the smooth and timely uploads of trips.
Allow background fetch for your app:
On the project screen, click Capabilities → Turn Background Modes on → Select Background Fetch

## Changes to Permission-related keys in `Info.plist`

In addition to location and motion related keys which were needed in the previous versions of the SDK, this version also needs bluetooth usage related keys. If you already have these keys present in your `Info.plist`, you don't me

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

### `DriverAttributes` changes

The `DriverAttributes` now accepts the `firstName` and `lastName` of the driver as separate parameters.

```diff
-    private let driverAttributes = DriverAttributes(name: "John Doe",
-                                                    email: "johndoe@company.com",
-                                                    phoneNumber: "+11234567890")
+    private let driverAttributes = DriverAttributes(
+        firstName: "John",
+        lastName: "Doe",
+        email: "johndoe@company.com",
+        phoneNumber: "+11234567890"
+    )
```

### Removal of `FairmaticDelegate`

The `FairmaticDelegate` protocol is no longer needed, and you can remove all the occurences of it in your code. Hence, the signature of the `Fairmatic.setup()` function has also changed to not accept the delegate parameter. This simplifies your app code.

```diff
-        Fairmatic.setupWith(configuration: configuration,
-                            delegate: self) { (success, error) in
+        Fairmatic.setupWith(configuration: configuration) { (success, error) in
```

### `trackingId` parameter for the `startPeriod1()` function.

Just like the `startPeriod2()` and `startPeriod3()` APIs, the `startPeriod1()` also accepts a `trackingId` parameter now making all three APIs consistent. 

### Removal of the `Fairmatic.isValidInputParameter()` method.

You no longer need to check your input strings using this method, as all the individual APIs of the SDK validate the strings and return appropriate errors if the strings are invalid.
