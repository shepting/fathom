//
//  UserAppID+Extension.swift
//  FathomUIKit
//
//  Created by Ethanhuang on 2018/7/17.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit
import FathomKit

extension UserApp {
    /// Returns unique bundle IDs from all AppIDs
    var uniqueBundleIDs: [String] {
        let bundleIDs = Set(appIDs.map { $0.bundleID })
        return bundleIDs.sorted()
    }

    /// Returns unique team IDs from all AppIDs
    var uniqueTeamIDs: [String] {
        let teamIDs = Set(appIDs.map { $0.teamID })
        return teamIDs.sorted()
    }

    var cellTitle: String {
        // Use app name if available, otherwise use first bundle ID
        if let app = self.app {
            return app.appName
        }
        return uniqueBundleIDs.first ?? ""
    }

    var cellSubtitle: String {
        // Display Bundle IDs
        let bundleIDs = uniqueBundleIDs
        let bundleIDLine: String
        if bundleIDs.count == 1 {
            bundleIDLine = "📦 Bundle ID: \(bundleIDs[0])"
        } else {
            bundleIDLine = "📦 Bundle IDs: \(bundleIDs.joined(separator: ", "))"
        }

        // Display all Team IDs
        let teamIDs = uniqueTeamIDs
        let teamIDLine: String
        if teamIDs.count == 1 {
            teamIDLine = "👥 Team ID: \(teamIDs[0])"
        } else {
            teamIDLine = "👥 Team IDs: \(teamIDs.joined(separator: ", "))"
        }

        // Display format
        let formatLine = format == .modern ? "📋 Format: Modern (iOS 13+)" : "📋 Format: Legacy"

        let pairs: [(Int, String)] = [
            (1, bundleIDLine),
            (1, teamIDLine),
            (1, formatLine),
            (paths?.count ?? 0, "🔗 %li Universal Links"),
            (supportsWebCredentials ? 1 : 0, "🤝 Activity Continuation"),
            (supportsActivityContinuation ? 1 : 0, "🔐 Web Credentials")
        ]

        return pairs.filter ({ $0.0 > 0 }).map({ String(format: $0.1, $0.0) }).joined(separator: "\n")
    }

    func fetchAll(completion: @escaping (_ result: Result<Void>) -> Void) {
        fetchApp { (result) in
            switch result {
            case .value(let app):
                UserApp.fetchIcon(url: app.iconURL, completion: { (result) in
                    switch result {
                    case .value(let image):
                        self.icon = image
                        completion(.value(()))
                    case .error(let error):
                        completion(.error(error))
                    }
                })
            case .error(let error):
                completion(.error(error))
            }
        }
    }

    private func fetchApp(completion: @escaping (_ result: Result<iTunesApp>) -> Void) {
        if let app = self.app {
            completion(.value(app))
        } else {
            iTunesSearchAPI.searchApp(bundleID: self.appID.bundleID) { (result) in
                switch result {
                case .value(let app):
                    self.app = app
                    completion(.value(app))
                case .error(let error):
                    completion(.error(error))
                }
            }
        }
    }

    private static func fetchIcon(url: URL, completion: @escaping (_ result: Result<UIImage>) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data,
                let icon = UIImage(data: data) {

                completion(.value(icon))
            } else {
                completion(.error(error ?? FathomKitError.noData))
            }
            }.resume()
    }
}
