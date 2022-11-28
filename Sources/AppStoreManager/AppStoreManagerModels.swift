//
//  AppStoreManagerModels.swift
//  AppStoreManager
//
//  Created by Developer on 16/3/21.
//

import Foundation

struct AppStoreResponse: Decodable {
    let resultCount: Int?
    let results: [AppStoreResult]
}

struct AppStoreResult: Decodable {
    let trackId: Int?
    let version: String?
    let currentVersionReleaseDate: Date?

    private enum CodingKeys: String, CodingKey {
        case trackId
        case version
        case currentVersionReleaseDate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.trackId = try? container.decodeIfPresent(Int.self, forKey: .trackId)
        self.version = try? container.decodeIfPresent(String.self, forKey: .version)
        if let date = try? container.decodeIfPresent(String.self, forKey: .currentVersionReleaseDate) {
            self.currentVersionReleaseDate = date.toDate(with: "yyyy-MM-dd'T'HH:mm:ssZ")
        } else {
            self.currentVersionReleaseDate = nil
        }
    }
}
