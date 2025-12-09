//
//  UserDefaults+Extension.swift
//  Fathom
//
//  Created by Ethanhuang on 2018/7/30.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import Foundation
import FathomKit

extension UserDefaults {
    private static let appStoreOptionKey = "com.elaborapp.Fathom.appStoreOptionKey"

    var appStoreOption: AppStoreOption {
        get {
            return AppStoreOption(rawValue: UserDefaults.standard.integer(forKey: UserDefaults.appStoreOptionKey)) ?? .storeProductViewController
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: UserDefaults.appStoreOptionKey)
        }
    }
}
