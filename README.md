**AppStoreManager** is a new version checking framework for iOS.

## 📝 How
### Code Implementation
First:
```swift
import SideMenu
```

```swift

AppStoreManager.shared.checkNewVersion { (isAvailable) in
    if isAvailable {
        //has new version available.
        AppStoreManager.shared.showAlertUpdate(at: self, canSkip: true)

    }else{
        //no new version.
    }
}

```
### Customization
#### AppStoreManager
`AppStoreManager` supports the following:
```swift
    AppStoreManager.shared.configureAlert(title: <#T##String?#>, message: <#T##String?#>)
    AppStoreManager.shared.configureAlert(updateButtonTitle: <#T##String?#>, skipButtonTitle: <#T##String?#>)
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
