//
//  AppDelegate.swift
//  ARKitStream
//
//  Created by LAP15651 on 03/11/2022.
//

import UIKit
import ARKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if !ARFaceTrackingConfiguration.isSupported {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            window?.rootViewController = storyboard.instantiateViewController(withIdentifier: "notSupport")
        }
        return true
    }

    // MARK: UISceneSession Lifecycle
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }


}

