//
//  AppDelegate.swift
//  Examples
//
//  Created by ALEXEY ABDULIN on 13/05/2020.
//  Copyright © 2020 ALEXEY ABDULIN. All rights reserved.
//

import UIKit
import BaseMVVM

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    var serviceFactory = SBDefaultServiceFactory()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        let cntrl = UIStoryboard( name: "Main", bundle: nil ).instantiateInitialViewController() as! SBNavigationController
        cntrl.BindVM( vm: MainViewModel( serviceFactory: serviceFactory ) )
        
        window = UIWindow()
        window?.rootViewController = cntrl
        window?.makeKeyAndVisible()
        
        return true
    }
}

