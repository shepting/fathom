//
//  AASA.swift
//  Knil
//
//  Created by Ethanhuang on 2018/6/25.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

public struct AASA: Codable {
    public let appLinks: AppLinks?
    public let webCredentials: AppIDsWrapper?
    public let activityContinuation: AppIDsWrapper?

    public enum CodingKeys: String, CodingKey {
        case appLinks = "applinks"
        case webCredentials = "webcredentials"
        case activityContinuation = "activitycontinuation"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        appLinks = try values.decodeIfPresent(AppLinks.self, forKey: .appLinks)
        webCredentials = try values.decodeIfPresent(AppIDsWrapper.self, forKey: .webCredentials)
        activityContinuation = try values.decodeIfPresent(AppIDsWrapper.self, forKey: .activityContinuation)

        if appLinks == nil
            && webCredentials == nil
            && activityContinuation == nil {
            throw KnilKitError.noData
        }
        
        self.logAASAFormat(source: "disk")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(appLinks, forKey: .appLinks)
        try container.encodeIfPresent(webCredentials, forKey: .webCredentials)
        try container.encodeIfPresent(activityContinuation, forKey: .activityContinuation)
    }

    public init(data: Data) throws {
        if var string = String(data: data, encoding: .ascii) {
            var startIndex = string.range(of: "{")?.lowerBound ?? string.startIndex
            var endIndex = string.range(of: "}", options: .backwards, range: nil, locale: nil)?.upperBound ?? string.endIndex

            while startIndex < endIndex {
                let substring = string[startIndex ..< endIndex]
                string = String(substring)

                if let currentData = string.data(using: .utf8),
                    let aasa = try? JSONDecoder().decode(AASA.self, from: currentData) {
                    self = aasa
                    self.logAASAFormat(source: "network")
                    return
                } else {
                    startIndex = string.startIndex

                    if let newEndIndex = string.range(of: "}", options: .backwards, range: string.startIndex ..< string.index(string.endIndex, offsetBy: -1), locale: nil)?.upperBound {
                        endIndex = newEndIndex
                    } else {
                        break
                    }
                }
            }
        }

        throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Cannot decode from data"))
    }
    
    private func logAASAFormat(source: String = "unknown") {
        let format = appLinks?.format ?? .legacy
        let formatString = format == .modern ? "New Format (iOS 13+)" : "Legacy Format"
        let sourceIcon = source == "network" ? "🌐" : source == "disk" ? "💾" : "📄"
        
        print("\(sourceIcon) AASA loaded from \(source): \(formatString)")
        
        if let appLinks = appLinks, format == .modern {
            let componentCount = appLinks.details.compactMap { $0.components }.flatMap { $0 }.count
            print("   • Contains \(componentCount) URL component(s) with advanced matching")
        } else if let appLinks = appLinks, format == .legacy {
            let pathCount = appLinks.details.compactMap { $0.paths }.flatMap { $0 }.count
            print("   • Contains \(pathCount) path pattern(s)")
        }
    }
}
