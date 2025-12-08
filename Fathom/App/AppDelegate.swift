//
//  AppDelegate.swift
//  Fathom
//
//  Created by Ethanhuang on 2018/6/25.
//  Copyright © 2018年 Elaborapp Co., Ltd. All rights reserved.
//

import UIKit
import FathomKit
import FathomUIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("Fathom app launched")

        UIView.appearance().tintColor = .tint

        window = UIWindow(frame: UIScreen.main.bounds)
        let rootViewController = TabBarController()
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()

        return true
    }
}

extension AppDelegate: URLOpener {
    func openURL(_ url: URL) -> Bool {
        print("Opening URL: \(url.absoluteString)")
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
        return true
    }
}

