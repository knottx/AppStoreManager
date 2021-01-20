//
//  AppStoreManager.swift
//  AppStoreManager
//
//  Created by Visarut Tippun on 8/1/21.
//

import UIKit

public enum VersionCheckType:Int {
    case immediately = 0
    case daily = 1
    case weekly = 7
}

enum AppStoreDefaults: String {
    case storedVersionCheckDate
    case storedSkippedVersion
}

struct AppStoreResponse: Decodable {
    var resultCount:Int?
    var results:[AppStoreResult]
}

struct AppStoreResult: Decodable {
    var trackId:Int?
    var version:String?
}

public class AppStoreManager {
    
    public static let shared = AppStoreManager()
    
    var title:String = "New version available"
    var message:String? = "There is an update available. Please update to use this application."
    
    var skipButtonTitle:String = "Skip"
    var updateButtonTitle:String = "Update"
    
    var lastVersionCheckDate:Date? {
        didSet{
            if let date = self.lastVersionCheckDate {
                UserDefaults.standard.set(date, forKey: AppStoreDefaults.storedVersionCheckDate.rawValue)
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    let bundleId = Bundle.main.bundleIdentifier ?? ""
    
    var currentInstalledVersion:String? {
        get {
            return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        }
    }
    
    var appStoreResult:AppStoreResult?
    
    init() {
        self.lastVersionCheckDate = UserDefaults.standard.object(forKey: AppStoreDefaults.storedVersionCheckDate.rawValue) as? Date
    }
    
    func getStoreVersion(completion: @escaping (AppStoreResult?) -> ()) {
        guard let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(self.bundleId)") else {
            completion(nil)
            return
        }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { (data, response, error) in
            if let er = error {
                self.log(er.localizedDescription)
                completion(nil)
            }
            if let safeData = data,
               let responseData = try? JSONDecoder().decode(AppStoreResponse.self, from: safeData),
               let result = responseData.results.first {
                self.log("AppStore ID: \(result.trackId ?? 0)")
                self.log("AppStore version: \(result.version ?? "")")
                self.appStoreResult = result
                completion(result)
            }else{
                self.appStoreResult = nil
                completion(nil)
            }
        }
        task.resume()
    }
    
    public func checkNewVersion(_ type:VersionCheckType, isAvailable: @escaping (Bool) -> ()) {
        self.getStoreVersion { (result) in
            if let currentInstalledVersion = self.currentInstalledVersion,
               let appStoreVersion = result?.version {
                switch currentInstalledVersion.compare(appStoreVersion, options: .numeric) {
                case .orderedAscending:
                    switch type {
                    case .immediately:
                        self.lastVersionCheckDate = Date()
                        isAvailable(true)
                    default:
                        guard let lastVersionCheckDate = self.lastVersionCheckDate else {
                            self.lastVersionCheckDate = Date()
                            isAvailable(true)
                            return
                        }
                        if Date.days(since: lastVersionCheckDate) >= type.rawValue {
                            self.lastVersionCheckDate = Date()
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
        self.getStoreVersion { (result) in
            if let currentInstalledVersion = self.currentInstalledVersion,
               let appStoreVersion = result?.version {
                switch currentInstalledVersion.compare(appStoreVersion, options: .numeric) {
                case .orderedAscending:
                    self.lastVersionCheckDate = Date()
                    self.showAlertUpdate(at: vc, canSkip: canSkip, preferredStyle: preferredStyle)
                case .orderedDescending, .orderedSame:
                    break
                }
            }
        }
    }
    
    //MARK: - Alert
    
    public func configureAlert(title:String?, message: String?) {
        self.title = title ?? "New version available"
        self.message = message
    }
    
    public func configureAlert(updateButtonTitle:String?, skipButtonTitle:String?) {
        self.updateButtonTitle = updateButtonTitle ?? "Update"
        self.skipButtonTitle = skipButtonTitle ?? "Skip"
    }
    
    public func showAlertUpdate(at vc:UIViewController, canSkip:Bool, preferredStyle:UIAlertController.Style = .alert) {
        DispatchQueue.main.async {
            let alertVc = UIAlertController(title: self.title, message: self.message, preferredStyle: preferredStyle)
            let skip = UIAlertAction(title: "Skip", style: .cancel) { (_) in
                //
            }
            let update = UIAlertAction(title: "Update", style: .default) { (_) in
                self.openAppStore()
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
            self.getStoreVersion { (result) in
                guard let appStoreId = result?.trackId else { return }
                self.openAppStore(id: appStoreId)
            }
        }
    }
    
    func openAppStore(id appStoreId:Int) {
        if let url = URL(string: "https://itunes.apple.com/app/id\(appStoreId)"),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func log(_ value: String) {
        print("📲: [AppStore] => \(value)")
    }
    
}

extension Date {
    
    static func days(since date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: date, to: Date())
        return components.day ?? 0
    }
    
}
