//
//  AppStoreManagerModels.swift
//  AppStoreManager
//
//  Created by Developer on 16/3/21.
//

import Foundation

struct AppStoreResponse: Decodable {
    var resultCount:Int?
    var results:[AppStoreResult]
}

struct AppStoreResult: Decodable {
    var trackId:Int?
    var version:String?
}
