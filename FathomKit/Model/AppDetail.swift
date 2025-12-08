//
//  AppDetail.swift
//  FathomKit
//
//  Created by Ethanhuang on 2018/7/10.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

public struct AppDetail: Codable {
    public let appID: AppID?
    public let appIDs: [AppID]?
    public let paths: [AppPath]?
    public let components: [URLComponent]?
    public let exclude: Bool?
    
    public var allAppIDs: [AppID] {
        if let appIDs = appIDs {
            return appIDs
        } else if let appID = appID {
            return [appID]
        }
        return []
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // Legacy format support
        appID = try values.decodeIfPresent(AppID.self, forKey: .appID)
        paths = try values.decodeIfPresent([AppPath].self, forKey: .paths)
        
        // New format support
        appIDs = try values.decodeIfPresent([AppID].self, forKey: .appIDs)
        components = try values.decodeIfPresent([URLComponent].self, forKey: .components)
        exclude = try values.decodeIfPresent(Bool.self, forKey: .exclude)
        
        // Ensure we have at least one app identifier
        if appID == nil && (appIDs?.isEmpty ?? true) {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.appID], debugDescription: "AppDetail must have appID or appIDs"))
        }
        
        // Ensure we have either paths or components
        if (paths?.isEmpty ?? true) && (components?.isEmpty ?? true) {
            throw DecodingError.dataCorrupted(.init(codingPath: [CodingKeys.paths], debugDescription: "AppDetail must have paths or components"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(appID, forKey: .appID)
        try container.encodeIfPresent(appIDs, forKey: .appIDs)
        try container.encodeIfPresent(paths, forKey: .paths)
        try container.encodeIfPresent(components, forKey: .components)
        try container.encodeIfPresent(exclude, forKey: .exclude)
    }
    
    enum CodingKeys: String, CodingKey {
        case appID
        case appIDs
        case paths
        case components
        case exclude
    }
}
