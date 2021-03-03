//
//  AppDelegate.swift
//  CarQR
//
//  Created by Huỳnh Đức Hoàng on 2/23/21.
//

import UIKit
import SwiftUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    static func sharedAppDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.initRootViewController()
        return true
    }
    
    func initRootViewController(){
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let qrViewController = TextViewController()
        let navigationController = UINavigationController(rootViewController: qrViewController)
        
        self.window?.backgroundColor = UIColor.white
        self.window?.rootViewController = navigationController
        
        self.window?.makeKeyAndVisible()
    }
}
