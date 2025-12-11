//
//  UserAppID.swift
//  FathomKit
//
//  Created by Ethanhuang on 2018/7/17.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit

public class UserApp: Codable {
    public let hostname: String
    public private(set) var appIDs: [AppID]

    /// For backward compatibility and convenience - returns the first AppID
    public var appID: AppID {
        return appIDs.first!
    }

    public private(set) var paths: [AppPath]?
    public private(set) var supportsAppLinks: Bool = false
    public private(set) var supportsWebCredentials: Bool = false
    public private(set) var supportsActivityContinuation: Bool = false

    public var app: iTunesApp?
    public var icon: UIImage?

    public enum CodingKeys: String, CodingKey {
        case hostname
        case appIDs
        case paths
        case supportsAppLinks
        case supportsWebCredentials
        case supportsActivityContinuation
    }

    public init(hostname: String, appID: AppID, aasa: AASA) {
        self.hostname = hostname
        self.appIDs = [appID]

        // Find AppDetail that contains this appID (supporting both legacy and new formats)
        let appDetail = aasa.appLinks?.details.first { detail in
            detail.allAppIDs.contains(appID)
        }

        // Get paths from either legacy format or convert from components
        if let detail = appDetail {
            var allPaths: [AppPath] = []

            // Add legacy format paths
            if let legacyPaths = detail.paths {
                allPaths.append(contentsOf: legacyPaths)
            }

            // Add component-based paths
            if let components = detail.components {
                let componentPaths = components.map { component in
                    AppPath(from: component, excluded: detail.exclude ?? false)
                }
                allPaths.append(contentsOf: componentPaths)
            }

            paths = allPaths.isEmpty ? nil : allPaths
        } else {
            paths = nil
        }

        supportsAppLinks = appDetail != nil
        supportsWebCredentials = aasa.webCredentials?.appIDs.contains(appID) == true
        supportsActivityContinuation = aasa.activityContinuation?.appIDs.contains(appID) == true
    }

    /// Creates a UserApp from multiple AppIDs that share the same content
    public init(hostname: String,
                appIDs: [AppID],
                paths: [AppPath]?,
                supportsAppLinks: Bool,
                supportsWebCredentials: Bool,
                supportsActivityContinuation: Bool) {
        self.hostname = hostname
        self.appIDs = appIDs
        self.paths = paths
        self.supportsAppLinks = supportsAppLinks
        self.supportsWebCredentials = supportsWebCredentials
        self.supportsActivityContinuation = supportsActivityContinuation
    }

    /// Adds additional AppIDs to this UserApp (used for merging apps with same content)
    internal func addAppIDs(_ newAppIDs: [AppID]) {
        var combined = appIDs
        for appID in newAppIDs where !combined.contains(appID) {
            combined.append(appID)
        }
        appIDs = combined.sorted { $0.bundleID < $1.bundleID }
    }

    internal func update(paths: [AppPath]?,
                         supportsAppLinks: Bool,
                         supportsWebCredentials: Bool,
                         supportsActivityContinuation: Bool) {
        print("UserApp \(self.appID) updated paths...")
        self.paths = paths
        self.supportsAppLinks = supportsAppLinks
        self.supportsWebCredentials = supportsWebCredentials
        self.supportsActivityContinuation = supportsActivityContinuation
    }
}
