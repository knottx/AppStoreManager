//
//  AppStoreManager.swift
//  AppStoreManager
//
//  Created by Visarut Tippun on 8/1/21.
//

import Foundation

public class AppStoreManager {
    
    public static let shared = AppStoreManager()
    
    public var currentInstalledVersion:String? {
        get {
            return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        }
    }
    
    
}
