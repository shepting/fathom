//
//  UserAASA.swift
//  FathomKit
//
//  Created by Ethanhuang on 2018/7/16.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

public class UserAASA: Codable {
    public private(set) var aasa: AASA
    public let fetchedDate: Date
    public let url: URL
    public let hostname: String
    public let userApps: [UserApp]
    public var customURLs: [URL: String]

    public init(aasa: AASA, from url: URL) {
        self.aasa = aasa
        self.fetchedDate = Date()
        self.url = url
        self.hostname = url.host?.lowercased() ?? ""
        self.userApps = UserAASA.extractUserApps(from: aasa, hostname: hostname)
        self.customURLs = [:]
        
        // Additional logging with hostname context
        let format = aasa.appLinks?.format ?? .legacy
        let formatString = format == .modern ? "New Format (iOS 13+)" : "Legacy Format"
        print("🏠 \(hostname): \(formatString)")
    }

    public func update(_ aasa: AASA) {
        let format = aasa.appLinks?.format ?? .legacy
        let formatString = format == .modern ? "New Format (iOS 13+)" : "Legacy Format"
        print("🔄 \(hostname) updated to: \(formatString)")
        self.aasa = aasa

        let newUserApps = UserAASA.extractUserApps(from: aasa, hostname: hostname)
        for newUserApp in newUserApps {
            // Match by bundle ID since apps are now grouped by content
            if let userApp = userApps.first(where: { $0.appID.bundleID == newUserApp.appID.bundleID }) {
                userApp.update(paths: newUserApp.paths,
                               supportsAppLinks: newUserApp.supportsAppLinks,
                               supportsWebCredentials: newUserApp.supportsWebCredentials,
                               supportsActivityContinuation: newUserApp.supportsActivityContinuation)
                userApp.addAppIDs(newUserApp.appIDs)
            }
        }
    }

    private static func extractUserApps(from aasa: AASA, hostname: String) -> [UserApp] {
        var allAppIDs: Set<AppID> = []

        // Extract app IDs from all sections
        for detail in aasa.appLinks?.details ?? [] {
            allAppIDs.formUnion(detail.allAppIDs)
        }
        allAppIDs.formUnion(aasa.webCredentials?.appIDs ?? [])
        allAppIDs.formUnion(aasa.activityContinuation?.appIDs ?? [])

        // Create temporary UserApp for each AppID to extract their content
        let tempUserApps = allAppIDs.map { UserApp(hostname: hostname, appID: $0, aasa: aasa) }

        // Group by content: paths, supportsAppLinks, supportsWebCredentials, supportsActivityContinuation
        // Create a unique key based on content
        struct ContentKey: Hashable {
            let paths: Set<AppPath>?
            let supportsAppLinks: Bool
            let supportsWebCredentials: Bool
            let supportsActivityContinuation: Bool
            let bundleID: String  // Group by bundle ID too

            init(userApp: UserApp) {
                self.paths = userApp.paths.map { Set($0) }
                self.supportsAppLinks = userApp.supportsAppLinks
                self.supportsWebCredentials = userApp.supportsWebCredentials
                self.supportsActivityContinuation = userApp.supportsActivityContinuation
                self.bundleID = userApp.appID.bundleID
            }
        }

        // Group apps by content
        var contentGroups: [ContentKey: [UserApp]] = [:]
        for userApp in tempUserApps {
            let key = ContentKey(userApp: userApp)
            contentGroups[key, default: []].append(userApp)
        }

        // Create merged UserApps for each content group
        var mergedUserApps: [UserApp] = []
        for (key, userApps) in contentGroups {
            let allAppIDsForGroup = userApps.map { $0.appID }
            let representative = userApps.first!

            let mergedUserApp = UserApp(
                hostname: hostname,
                appIDs: allAppIDsForGroup.sorted { $0.teamID < $1.teamID },
                paths: representative.paths,
                supportsAppLinks: key.supportsAppLinks,
                supportsWebCredentials: key.supportsWebCredentials,
                supportsActivityContinuation: key.supportsActivityContinuation
            )
            mergedUserApps.append(mergedUserApp)
        }

        // Sort by bundle ID for consistent ordering
        return mergedUserApps.sorted { $0.appID.bundleID < $1.appID.bundleID }
    }
}
