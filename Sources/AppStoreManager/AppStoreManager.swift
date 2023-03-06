//
//  .swift
//  AppStoreManager
//
//  Created by Visarut Tippun on 8/1/21.
//

#if canImport(UIKit)

import UIKit

public enum VersionCheckType: Int {
    case immediately = 0
    case daily = 1
    case weekly = 7
}

enum AppStoreDefaults {
    static let storedVersionCheckDate = "storedVersionCheckDate"
    static let storedSkippedVersion = "storedSkippedVersion"
}

public class AppStoreManager {
    public static let shared = AppStoreManager()

    var title: String = AppStoreManagerConstant.alertTitle
    var message: String? = AppStoreManagerConstant.alertMessage

    var skipButtonTitle: String = AppStoreManagerConstant.skipButtonTitle
    var updateButtonTitle: String = AppStoreManagerConstant.updateButtonTitle

    var lastVersionCheckDate: Date? {
        didSet {
            UserDefaults.standard.set(self.lastVersionCheckDate, forKey: AppStoreDefaults.storedVersionCheckDate)
            UserDefaults.standard.synchronize()
        }
    }

    let bundleId = Bundle.main.bundleIdentifier ?? ""

    var currentInstalledVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

    var appStoreResult: AppStoreResult?

    init() {
        self.lastVersionCheckDate = UserDefaults.standard.object(forKey: AppStoreDefaults.storedVersionCheckDate) as? Date
    }

    private func getStoreVersion(countryCode: String?,
                                 completion: @escaping (AppStoreResult?) -> Void) {
        var baseUrl = "https://itunes.apple.com"
        if let code = countryCode {
            baseUrl.append("/\(code)")
        }
        baseUrl.append("/lookup?bundleId=\(self.bundleId)")
        guard let url = URL(string: baseUrl) else {
            completion(nil)
            return
        }
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: url) { [weak self] data, _, error in
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
            } else {
                self?.appStoreResult = nil
                completion(nil)
            }
        }
        task.resume()
    }

    public func checkNewVersion(_ type: VersionCheckType,
                                countryCode: String? = nil,
                                isAvailable: @escaping (Bool) -> Void) {
        self.getStoreVersion(countryCode: countryCode) { [weak self] result in
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
                        } else {
                            isAvailable(false)
                        }
                    }
                case .orderedDescending, .orderedSame:
                    isAvailable(false)
                }
            } else {
                self?.log("Can't get Version")
                isAvailable(false)
            }
        }
    }

    public func checkNewVersionAndShowAlert(_ type: VersionCheckType,
                                            countryCode: String? = nil,
                                            at vc: UIViewController,
                                            canSkip: Bool) {
        self.checkNewVersion(type) { [weak self] isAvailable in
            if isAvailable {
                self?.showAlertUpdate(at: vc, canSkip: canSkip)
            }
        }
    }

    // MARK: - Alert

    public func configureAlert(title: String?,
                               message: String?) {
        self.title = title ?? AppStoreManagerConstant.alertTitle
        self.message = message
    }

    public func configureAlert(updateButtonTitle: String?,
                               skipButtonTitle: String?) {
        self.updateButtonTitle = updateButtonTitle ?? AppStoreManagerConstant.updateButtonTitle
        self.skipButtonTitle = skipButtonTitle ?? AppStoreManagerConstant.skipButtonTitle
    }

    public func showAlertUpdate(countryCode: String? = nil,
                                at vc: UIViewController,
                                canSkip: Bool) {
        DispatchQueue.main.async { [weak self] in
            let alertVc = UIAlertController(title: self?.title,
                                            message: self?.message,
                                            preferredStyle: .alert)
            let skip = UIAlertAction(title: self?.skipButtonTitle ?? AppStoreManagerConstant.skipButtonTitle, style: .cancel) { _ in
                //
            }
            let update = UIAlertAction(title: self?.updateButtonTitle ?? AppStoreManagerConstant.updateButtonTitle, style: .default) { _ in
                self?.openAppStore(countryCode: countryCode)
            }
            alertVc.addAction(update)
            if canSkip {
                alertVc.addAction(skip)
            }
            vc.present(alertVc, animated: true, completion: nil)
        }
    }

    public func openAppStore(countryCode: String? = nil) {
        if let appStoreId = self.appStoreResult?.trackId {
            self.openAppStore(countryCode: countryCode,
                              id: appStoreId)
        } else {
            self.getStoreVersion(countryCode: countryCode) { [weak self] result in
                guard let appStoreId = result?.trackId else {
                    self?.log("Can't get an AppId")
                    return
                }
                self?.openAppStore(countryCode: countryCode,
                                   id: appStoreId)
            }
        }
    }

    private func openAppStore(countryCode: String?,
                              id appStoreId: Int) {
        var baseUrl = "https://itunes.apple.com"
        if let code = countryCode {
            baseUrl.append("/\(code)")
        }
        baseUrl.append("/app/id\(appStoreId)")
        if let url = URL(string: baseUrl),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            self.log("Can't open AppStore")
        }
    }

    func log(_ value: String) {
        print("📲: [AppStore] => \(value)")
    }
}

#endif
