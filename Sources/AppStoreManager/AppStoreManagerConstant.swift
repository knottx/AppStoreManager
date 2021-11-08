//
//  AppStoreManagerConstant.swift
//  AppStoreManager
//
//  Created by Developer on 16/3/21.
//

import Foundation

struct AppStoreManagerConstant {
    static let alertTitle = "New version available"
    static let alertMessage = "There is an update available. Please update to use this application."
    static let skipButtonTitle = "Skip"
    static let updateButtonTitle = "Update"
}


extension Date {
    
    static func days(since date: Date) -> Int {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.day], from: date, to: Date())
        return components.day ?? 0
    }
    
}


extension String {
    
    func toDate(with format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: self)
        return date
    }

}
