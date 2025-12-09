//
//  AppLinks.swift
//  FathomKit
//
//  Created by Ethanhuang on 2018/7/10.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

public enum AASAFormat {
    case legacy    // Uses "paths" key
    case modern    // Uses "components" key (WWDC 2019)
}

/// Used to decode legacy dictionary format where details is keyed by app ID
struct LegacyAppDetail: Codable {
    let paths: [AppPath]?
    let components: [URLComponent]?
}

public struct AppLinks: Codable {
    /// The apps key in an apple-app-site-association file must be present and its value must be an empty array
    public let apps: [AppID]?
    public let details: [AppDetail]
    
    public var format: AASAFormat {
        // Check if any AppDetail has components - this is the key indicator
        return details.contains { $0.components != nil } ? .modern : .legacy
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        apps = try values.decodeIfPresent([AppID].self, forKey: .apps)

        // Try to decode as array first (modern format)
        if let arrayDetails = try? values.decode([AppDetail].self, forKey: .details) {
            details = arrayDetails
        } else {
            // Fall back to dictionary format (legacy format where keys are app IDs)
            let dictDetails = try values.decode([String: LegacyAppDetail].self, forKey: .details)
            details = dictDetails.compactMap { (appIDString, detail) in
                guard let appID = AppID(string: appIDString) else { return nil }
                return AppDetail(appID: appID, paths: detail.paths, components: detail.components)
            }
        }
    }
}
