**AppStoreManager** is a new version checking framework for iOS.

## 📝 How
### Code Implementation
First:
```swift
import AppStoreManager
```

Show alert when update available, do something like this:
```swift
//  Can select version check type => .immediately, .daily, .weekly
AppStoreManager.shared.checkNewVersionAndShowAlert(.immediately, at: self, canSkip: true, preferredStyle: .alert)
//  If you don't need to show skip button, you can set the 'canSkip: false'
//  PreferredStyle default is '.alert', Can be select between '.alert' and '.actionSheet'
```

For handle when update available, do something like this:
```swift
//  Can select version check type => .immediately, .daily, .weekly
AppStoreManager.shared.checkNewVersion(.immediately) { (isAvailable) in
    if isAvailable {
        //  has new version available.
        AppStoreManager.shared.showAlertUpdate(at: self, canSkip: true, preferredStyle: .alert)
        //  If you don't need to show skip button, you can set the 'canSkip: false'
        //  PreferredStyle default is '.alert', Can be select between '.alert' and '.actionSheet'
    }else{
        //  no new version.
    }
}
```
### Customization
#### AppStoreManager
`AppStoreManager` supports the following:
```swift

AppStoreManager.shared.configureAlert(title: <String?>, message: <String?>)
//  Default title is "New version available"
//  Default message is "There is an update available. Please update to use this application.", message is optional.

AppStoreManager.shared.configureAlert(updateButtonTitle: <String?>, skipButtonTitle: <String?>)
//  Default updateButtonTitle is "Update"
//  Default skipButtonTitle is "Skip"
```

## 📋 Requirements

* iOS 10.0+
* Xcode 11+
* Swift 5.1+

## 📲 Installation

`AppStoreManager` is available on [CocoaPods](https://cocoapods.org/pods/AppStoreManager):

```ruby
pod 'AppStoreManager'
```
