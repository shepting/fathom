//
//  UIColor+Extension.swift
//  FathomUIKit
//
//  Created by Ethanhuang on 2018/7/30.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit

extension UIColor {
    public static let barTint: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0) // Dark gray
                default:
                    return UIColor.black
                }
            }
        } else {
            return UIColor.black
        }
    }()

    public static let tint: UIColor = #colorLiteral(red: 1, green: 0.5803921569, blue: 0.1450980392, alpha: 1) // Orange - same in both modes

    public static let background: UIColor = {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .dark:
                    return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0) // Black
                default:
                    return #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1) // Light gray
                }
            }
        } else {
            return #colorLiteral(red: 0.9803921569, green: 0.9803921569, blue: 0.9803921569, alpha: 1)
        }
    }()
}
