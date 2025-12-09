//
//  AASA.swift
//  Fathom
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
            throw FathomKitError.noData
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
        // Try multiple string encodings
        let encodings: [String.Encoding] = [.utf8, .ascii, .isoLatin1]

        for encoding in encodings {
            guard let string = String(data: data, encoding: encoding) else { continue }

            // Find JSON by looking for AASA key markers
            let jsonMarkers = ["\"applinks\"", "\"webcredentials\"", "\"activitycontinuation\""]

            // Find the earliest marker position
            var earliestMarkerIndex: String.Index?
            for marker in jsonMarkers {
                if let range = string.range(of: marker) {
                    if earliestMarkerIndex == nil || range.lowerBound < earliestMarkerIndex! {
                        earliestMarkerIndex = range.lowerBound
                    }
                }
            }

            // If we found a marker, search backwards for the opening brace
            if let markerIndex = earliestMarkerIndex {
                let prefixRange = string.startIndex..<markerIndex
                if let openBraceRange = string.range(of: "{", options: .backwards, range: prefixRange) {
                    let startIndex = openBraceRange.lowerBound

                    // Try progressively shorter substrings ending with }
                    var searchEndIndex = string.endIndex
                    while searchEndIndex > startIndex {
                        if let closeBraceRange = string.range(of: "}", options: .backwards, range: startIndex..<searchEndIndex) {
                            let endIndex = closeBraceRange.upperBound
                            let jsonCandidate = String(string[startIndex..<endIndex])

                            if let jsonData = jsonCandidate.data(using: .utf8),
                               let aasa = try? JSONDecoder().decode(AASA.self, from: jsonData) {
                                self = aasa
                                self.logAASAFormat(source: "network")
                                return
                            }

                            // Move search end to before this closing brace
                            searchEndIndex = closeBraceRange.lowerBound
                        } else {
                            break
                        }
                    }
                }
            }

            // Fallback: try the original approach for simple unsigned files
            if let firstBrace = string.range(of: "{"),
               let lastBrace = string.range(of: "}", options: .backwards) {
                let jsonCandidate = String(string[firstBrace.lowerBound..<lastBrace.upperBound])
                if let jsonData = jsonCandidate.data(using: .utf8),
                   let aasa = try? JSONDecoder().decode(AASA.self, from: jsonData) {
                    self = aasa
                    self.logAASAFormat(source: "network")
                    return
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
