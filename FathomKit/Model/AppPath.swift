//
//  AppPath.swift
//  FathomKit
//
//  Created by Ethanhuang on 2018/7/10.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

/// Note that only the path component of the URL is used for comparison. Other components, such as the query string or fragment identifier, are ignored.
public struct AppPath: Codable, Hashable, Equatable {
    /// The strings you use to specify website paths is case sensitive.
    public let pathString: String
    public let excluded: Bool
    public let queryComponent: QueryComponent?
    public let fragmentString: String?
    public let isComponentBased: Bool

    public init(from decoder: Decoder) throws {
        let values = try decoder.singleValueContainer()
        let string = try values.decode(String.self)

        if string.hasPrefix("NOT ") {
            excluded = true
            pathString = string.replacingOccurrences(of: "NOT ", with: "")
        } else {
            excluded = false
            pathString = string
        }
        
        // Legacy format - no query or fragment components
        self.queryComponent = nil
        self.fragmentString = nil
        self.isComponentBased = false
    }
    
    public init(from component: URLComponent, excluded: Bool = false) {
        self.pathString = component.path ?? "*"
        self.queryComponent = component.query
        self.fragmentString = component.fragment
        self.excluded = excluded
        self.isComponentBased = true
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let string = (excluded ? "NOT " : "") + pathString
        try container.encode(string)
    }
    
    public var fullDisplayString: String {
        var result = excluded ? "NOT " : ""
        result += pathString
        
        if let query = queryComponent {
            switch query {
            case .string(let queryString):
                result += "?\(queryString)"
            case .dictionary(let queryDict):
                let queryItems = queryDict.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
                result += "?\(queryItems)"
            }
        }
        
        if let fragment = fragmentString {
            result += "#\(fragment)"
        }
        
        return result
    }
}

extension AppPath {
    public func url(hostname: Hostname) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = hostname

        if pathString == "*" {
            urlComponents.path = ""
        } else {
            urlComponents.path = pathString
        }
        return urlComponents.url
    }
}
