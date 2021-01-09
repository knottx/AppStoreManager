//
//  AppStoreManager.swift
//  AppStoreManager
//
//  Created by Visarut Tippun on 8/1/21.
//

import UIKit

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
    
    let bundleId = Bundle.main.bundleIdentifier ?? ""
    
    var currentInstalledVersion:String? {
        get {
            return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        }
    }
    
    var appStoreResult:AppStoreResult?
    
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
    
    public func checkNewVersion(isAvailable: @escaping (Bool) -> ()) {
        self.getStoreVersion { (result) in
            if let currentInstalledVersion = self.currentInstalledVersion,
               let appStoreVersion = result?.version {
                switch currentInstalledVersion.compare(appStoreVersion, options: .numeric) {
                case .orderedAscending:
                    isAvailable(true)
                case .orderedDescending, .orderedSame:
                    isAvailable(false)
                }
            }else{
                isAvailable(false)
            }
        }
    }
    
    public func checkNewVersionAvailable(at vc:UIViewController, canSkip:Bool, preferredStyle: UIAlertController.Style = .alert) {
        self.getStoreVersion { (result) in
            if let currentInstalledVersion = self.currentInstalledVersion,
               let appStoreVersion = result?.version {
                switch currentInstalledVersion.compare(appStoreVersion, options: .numeric) {
                case .orderedAscending:
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
            guard let appStoreId = self.appStoreResult?.trackId else { return }
            let alertVc = UIAlertController(title: self.title, message: self.message, preferredStyle: preferredStyle)
            let skip = UIAlertAction(title: "Skip", style: .cancel, handler: nil)
            let update = UIAlertAction(title: "Update", style: .default) { (_) in
                if let url = URL(string: "https://itunes.apple.com/app/id\(appStoreId)"),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            alertVc.addAction(update)
            if canSkip {
                alertVc.addAction(skip)
            }
            vc.present(alertVc, animated: true, completion: nil)
        }
    }
    
    func log(_ value: String) {
        print("📲: [AppStore] => \(value)")
    }
    
}
