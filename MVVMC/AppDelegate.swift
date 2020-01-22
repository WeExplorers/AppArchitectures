//
//  AppDelegate.swift
//  MVVMC
//
//  Created by Evan Xie on 2020/1/22.
//  Copyright © 2020 Evan Xie. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .white
        
        let viewModel = LoginViewModel()
        let loginVC = LoginViewController(viewModel: viewModel)
        window?.rootViewController = loginVC
        window?.makeKeyAndVisible()
        return true
    }

}

