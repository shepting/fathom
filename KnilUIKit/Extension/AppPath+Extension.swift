//
//  AppPath+Extension.swift
//  KnilUIKit
//
//  Created by Ethanhuang on 2018/7/17.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation
import KnilKit

extension AppPath {
    var cellTitle: String {
        return isComponentBased ? fullDisplayString : (excluded ? "NOT \(pathString)" : pathString)
    }
    
    var cellSubtitle: String? {
        guard isComponentBased else { return nil }
        
        var details: [String] = []
        
        if let query = queryComponent {
            switch query {
            case .string:
                details.append("Query pattern matching")
            case .dictionary(let dict):
                details.append("Query: \(dict.count) parameter(s)")
            }
        }
        
        if fragmentString != nil {
            details.append("Fragment matching")
        }
        
        return details.isEmpty ? nil : details.joined(separator: " • ")
    }
}
