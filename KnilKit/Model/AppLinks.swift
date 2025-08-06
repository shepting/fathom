//
//  AppLinks.swift
//  KnilKit
//
//  Created by Ethanhuang on 2018/7/10.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

public enum AASAFormat {
    case legacy    // Uses "paths" key
    case modern    // Uses "components" key (WWDC 2019)
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

        details = try values.decode([AppDetail].self, forKey: .details)

    }
}
