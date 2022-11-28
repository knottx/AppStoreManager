**AppStoreManager** is a new version checking framework for iOS.

## 📲 Installation
### CocoaPods
`AppStoreManager` is available on [CocoaPods](https://cocoapods.org/pods/AppStoreManager):

```ruby
pod 'AppStoreManager'
```

### Swift Package Manager
- File > Swift Packages > Add Package Dependency
- Add `https://github.com/knottx/AppStoreManager.git`
- Select "Up to Next Major" with "1.3.4"

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

For open AppStore, do something like this:
```swift
AppStoreManager.shared.openAppStore()
//  go to AppStore for update your Application
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

* iOS 11.0+
* Xcode 11+
* Swift 5.1+
