//
//  UserAASA+Extension.swift
//  FathomUIKit
//
//  Created by Ethanhuang on 2018/7/16.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation
import FathomKit

extension UserAASA {
    var cellTitle: String {
        return hostname
    }

    var cellSubtitle: String {
        // Display format
        let format = aasa.appLinks?.format ?? .legacy
        let formatLine = format == .modern ? "📋 Format: Modern (iOS 13+)" : "📋 Format: Legacy"

        // Use singular/plural for Apps
        let appCount = userApps.count
        let appLine = appCount == 1 ? "💡 1 App" : "💡 \(appCount) Apps"

        let pairs: [(Int?, String)] = [
            (0, "🌎 \(url.absoluteString)"),
            (0, appLine),
            (aasa.appLinks?.details.count, "🔗 %li App Links"), // App Links
            (aasa.activityContinuation?.appIDs.count, "🤝 %li Activity Continuation"), // Activity Continuation
            (aasa.webCredentials?.appIDs.count, "🔐 %li Web Credentials"), // Web Credentials
            (0, formatLine) // Format (always show)
        ]

        return pairs.filter({ $0.0 != nil }).map ({ String(format: $0.1, $0.0!) }).joined(separator: "\n")
    }
}
