//
//  AppStoreManager.swift
//  AppStoreManager
//
//  Created by Visarut Tippun on 8/1/21.
//

import Alamofire
import RxSwift
import RxCocoa
import RxAlamofire

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
    private let bag = DisposeBag()
    
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
    
    
    func getStoreVersion() -> Observable<AppStoreResult?> {
        return Observable.create { (observable) -> Disposable in
            AF.rx.request(.get, "https://itunes.apple.com/lookup?bundleId=\(self.bundleId)").responseJSON().subscribe { (response) in
                switch response.result {
                case .success:
                    if let data = response.data,
                       let responseData = try? JSONDecoder().decode(AppStoreResponse.self, from: data),
                       let result = responseData.results.first {
                        self.log("AppStore ID: \(result.trackId ?? 0)")
                        self.log("AppStore version: \(result.version ?? "")")
                        self.appStoreResult = result
                        observable.onNext(result)
                        observable.onCompleted()
                    }else{
                        self.appStoreResult = nil
                        observable.onNext(nil)
                        observable.onCompleted()
                    }
                case .failure(let error):
                    observable.onError(error)
                }
            } onError: { (error) in
                observable.onError(error)
            }.disposed(by: self.bag)
            
            return Disposables.create()
        }
    }
    
    public func checkNewVersion(isAvailable: @escaping (Bool) -> ()) {
        self.getStoreVersion().subscribe { (result) in
            if let currentInstalledVersion = self.currentInstalledVersion,
               let appStoreVersion = result?.version {
                switch currentInstalledVersion.compare(appStoreVersion, options: .numeric) {
                case .orderedAscending:
                    isAvailable(true)
                case .orderedDescending, .orderedSame:
                    isAvailable(false)
                }
            }
        } onError: { (error) in
            self.log(error.localizedDescription)
            isAvailable(false)
        }.disposed(by: self.bag)
    }
    
    public func checkNewVersionAvailable(at vc:UIViewController, canSkip:Bool, preferredStyle: UIAlertController.Style = .alert) {
        self.getStoreVersion().subscribe { (result) in
            if let currentInstalledVersion = self.currentInstalledVersion,
               let appStoreVersion = result?.version {
                switch currentInstalledVersion.compare(appStoreVersion, options: .numeric) {
                case .orderedAscending:
                    self.showAlertUpdate(at: vc, canSkip: canSkip, preferredStyle: preferredStyle)
                case .orderedDescending, .orderedSame:
                    break
                }
            }
        } onError: { (error) in
            self.log(error.localizedDescription)
        }.disposed(by: self.bag)
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
    
    func log(_ value: String) {
        print("📲: [AppStore] => \(value)")
    }
    
}
