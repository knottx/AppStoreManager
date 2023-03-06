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
- Select "Up to Next Major" with "1.3.5"

## 📝 How

### Code Implementation

First:

```swift
import AppStoreManager
```

Check New Version Available:

- Can select version check type => `.immediately`, `.daily`, `.weekly`


    ```swift
    AppStoreManager.shared.checkNewVersion(.immediately) { (isAvailable) in
        if isAvailable {
            //  New Version Available.
        } else {
            //  No New Version.
        }
    }
    ```
    
- If your app is only available outside the U.S. App Store, you will need to set **countryCode** to the two-letter country code of the store you want to search. 
    > See http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 for a list of ISO Country Codes.
    
    ```swift
    AppStoreManager.shared.checkNewVersion(.immediately, countryCode: "th") { (isAvailable) in
        if isAvailable {
            //  New Version Available.
        } else {
            //  No New Version.
        }
    }
    ```


Check New Version Available and Show Alert:

- Can select version check type => `.immediately`, `.daily`, `.weekly`
- If you don't need to show skip button, you can set the **canSkip:** `false`

    ```swift
    AppStoreManager.shared.checkNewVersionAndShowAlert(.immediately, at: self, canSkip: true)
    ```

- If your app is only available outside the U.S. App Store, you will need to set **countryCode** to the two-letter country code of the store you want to search. 
    > See http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 for a list of ISO Country Codes.
    
    ```swift
    AppStoreManager.shared.checkNewVersionAndShowAlert(.immediately, countryCode: "th", at: self, canSkip: true)
    ```


Open AppStore:

    ```swift
    AppStoreManager.shared.openAppStore()
    ```

- If your app is only available outside the U.S. App Store, you will need to set **countryCode** to the two-letter country code of the store you want to search. 
    > See http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 for a list of ISO Country Codes.
    
    ```swift
    AppStoreManager.shared.openAppStore(countryCode: "th")
    ```

Alert Open AppStore:

- If you don't need to show skip button, you can set the **canSkip:** `false`
- **preferredStyle** default is `.alert`, Can be select between `.alert` and `.actionSheet`

    ```swift
    AppStoreManager.shared.showAlertUpdate(at: self, canSkip: true)
    ```
    
- If your app is only available outside the U.S. App Store, you will need to set **countryCode** to the two-letter country code of the store you want to search. 
    > See http://en.wikipedia.org/wiki/ISO_3166-1_alpha-2 for a list of ISO Country Codes.
    
    ```swift
    AppStoreManager.shared.showAlertUpdate(countryCode: "th",at: self, canSkip: true)
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
