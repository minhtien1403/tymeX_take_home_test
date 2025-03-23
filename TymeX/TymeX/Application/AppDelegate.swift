//
//  AppDelegate.swift
//  TymeX
//
//  Created by Trần Tiến on 18/3/25.
//

import UIKit
import Combine

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var appFlowCoordinator: AppFlowCoordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        let navi = UINavigationController()
        window?.rootViewController = navi
        appFlowCoordinator = AppFlowCoordinator(navigationController: navi)
        appFlowCoordinator?.start()
        window?.makeKeyAndVisible()
        CacheManager.shared.cleanExpiredCache()
        return true
    }
}

