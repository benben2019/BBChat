//
//  AppDelegate.swift
//  BBChat
//
//  Created by Ben on 2020/5/22.
//  Copyright © 2020 Benben. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
//        window?.rootViewController = UINavigationController(rootViewController: MessageListViewController())
        window?.rootViewController = ContainerViewController()
        window?.makeKeyAndVisible()
        
        FirebaseApp.configure()
        
        
        return true
    }

}

