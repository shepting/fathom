//
//  URLComponent.swift
//  FathomKit
//
//  Created by Claude on 2025/8/1.
//  Copyright © 2025年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation

public struct URLComponent: Codable {
    public let path: String?
    public let query: QueryComponent?
    public let fragment: String?
    
    enum CodingKeys: String, CodingKey {
        case path = "/"
        case query = "?"
        case fragment = "#"
    }
}

public enum QueryComponent: Codable {
    case string(String)
    case dictionary([String: String])
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let dict = try? container.decode([String: String].self) {
            self = .dictionary(dict)
        } else {
            throw DecodingError.typeMismatch(QueryComponent.self, 
                DecodingError.Context(codingPath: decoder.codingPath, 
                debugDescription: "Invalid query component"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let string):
            try container.encode(string)
        case .dictionary(let dict):
            try container.encode(dict)
        }
    }
}