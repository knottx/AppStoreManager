//
//  .swift
//  AppStoreManager
//
//  Created by Visarut Tippun on 8/1/21.
//

#if canImport(UIKit)

import UIKit

public enum VersionCheckType:Int {
    case immediately = 0
    case daily = 1
    case weekly = 7
}

struct AppStoreDefaults {
    static let storedVersionCheckDate = "storedVersionCheckDate"
    static let storedSkippedVersion = "storedSkippedVersion"
}

public class AppStoreManager {
    
    public static let shared = AppStoreManager()
    
    var title:String = AppStoreManagerConstant.alertTitle
    var message:String? = AppStoreManagerConstant.alertMessage
    
    var skipButtonTitle:String = AppStoreManagerConstant.skipButtonTitle
    var updateButtonTitle:String = AppStoreManagerConstant.updateButtonTitle
    
    var lastVersionCheckDate:Date? {
        didSet{
            UserDefaults.standard.set(self.lastVersionCheckDate, forKey: AppStoreDefaults.storedVersionCheckDate)
            UserDefaults.standard.synchronize()
        }
    }
    
    let bundleId = Bundle.main.bundleIdentifier ?? ""
    
    var currentInstalledVersion:String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    var appStoreResult:AppStoreResult?
    
    init() {
        self.lastVersionCheckDate = UserDefaults.standard.object(forKey: AppStoreDefaults.storedVersionCheckDate) as? Date
    }
    
    func getStoreVersion(completion: @escaping (AppStoreResult?) -> ()) {
        guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(self.bundleId)") else {
            completion(nil)
            return
        }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { [weak self] (data, response, error) in
            if let er = error {
                self?.log(er.localizedDescription)
                completion(nil)
            }
            if let safeData = data,
               let responseData = try? JSONDecoder().decode(AppStoreResponse.self, from: safeData),
               let result = responseData.results.first {
                self?.log("AppStore ID: \(result.trackId ?? 0)")
                self?.log("AppStore version: \(result.version ?? "")")
                self?.appStoreResult = result
                completion(result)
            }else{
                self?.appStoreResult = nil
                completion(nil)
            }
        }
        task.resume()
    }
    
    public func checkNewVersion(_ type:VersionCheckType, isAvailable: @escaping (Bool) -> ()) {
        self.getStoreVersion { [weak self] (result) in
            if let currentInstalledVersion = self?.currentInstalledVersion,
               let appStoreVersion = result?.version {
                switch currentInstalledVersion.compare(appStoreVersion, options: .numeric) {
                case .orderedAscending:
                    switch type {
                    case .immediately:
                        self?.lastVersionCheckDate = Date()
                        isAvailable(true)
                    default:
                        guard let lastVersionCheckDate = self?.lastVersionCheckDate else {
                            self?.lastVersionCheckDate = Date()
                            isAvailable(true)
                            return
                        }
                        if Date.days(since: lastVersionCheckDate) >= type.rawValue {
                            self?.lastVersionCheckDate = Date()
                            isAvailable(true)
                        }else{
                            isAvailable(false)
                        }
                    }
                case .orderedDescending, .orderedSame:
                    isAvailable(false)
                }
            }else{
                isAvailable(false)
            }
        }
    }
    
    public func checkNewVersionAndShowAlert(_ type:VersionCheckType,at vc:UIViewController, canSkip:Bool, preferredStyle: UIAlertController.Style = .alert) {
        self.getStoreVersion { [weak self] (result) in
            if let currentInstalledVersion = self?.currentInstalledVersion,
               let appStoreVersion = result?.version {
                switch currentInstalledVersion.compare(appStoreVersion, options: .numeric) {
                case .orderedAscending:
                    self?.lastVersionCheckDate = Date()
                    self?.showAlertUpdate(at: vc, canSkip: canSkip, preferredStyle: preferredStyle)
                case .orderedDescending, .orderedSame:
                    break
                }
            }else{
                self?.log("Can't get Version")
            }
        }
    }
    
    //MARK: - Alert
    
    public func configureAlert(title:String?, message: String?) {
        self.title = title ?? AppStoreManagerConstant.alertTitle
        self.message = message
    }
    
    public func configureAlert(updateButtonTitle:String?, skipButtonTitle:String?) {
        self.updateButtonTitle = updateButtonTitle ?? AppStoreManagerConstant.updateButtonTitle
        self.skipButtonTitle = skipButtonTitle ?? AppStoreManagerConstant.skipButtonTitle
    }
    
    public func showAlertUpdate(at vc:UIViewController, canSkip:Bool, preferredStyle:UIAlertController.Style = .alert) {
        DispatchQueue.main.async { [weak self] in
            let alertVc = UIAlertController(title: self?.title, message: self?.message, preferredStyle: preferredStyle)
            let skip = UIAlertAction(title: AppStoreManagerConstant.skipButtonTitle, style: .cancel) { (_) in
                //
            }
            let update = UIAlertAction(title: AppStoreManagerConstant.updateButtonTitle, style: .default) { (_) in
                self?.openAppStore()
            }
            alertVc.addAction(update)
            if canSkip {
                alertVc.addAction(skip)
            }
            vc.present(alertVc, animated: true, completion: nil)
        }
    }
    
    public func openAppStore() {
        if let appStoreId = self.appStoreResult?.trackId {
            self.openAppStore(id: appStoreId)
        }else{
            self.getStoreVersion { [weak self] (result) in
                guard let appStoreId = result?.trackId else {
                    self?.log("Can't get an AppId")
                    return
                }
                self?.openAppStore(id: appStoreId)
            }
        }
    }
    
    func openAppStore(id appStoreId:Int) {
        if let url = URL(string: "https://itunes.apple.com/app/id\(appStoreId)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }else{
            self.log("Can't open AppStore")
        }
    }
    
    func log(_ value: String) {
        print("📲: [AppStore] => \(value)")
    }
    
}


#endif
