//
//  AppDelegate.swift
//  jPixels
//
//  Created by Jeevan on 06/07/18.
//  Copyright © 2018 Jeevan. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let colorFloatsArray: [(CGFloat, CGFloat, CGFloat)] = [
        (0, 0, 0),
        (105.0 / 255.0, 105.0 / 255.0, 105.0 / 255.0),
        (1.0, 0, 0),
        (0, 0, 1.0),
        (51.0 / 255.0, 204.0 / 255.0, 1.0),
        (102.0 / 255.0, 204.0 / 255.0, 0),
        (102.0 / 255.0, 1.0, 0),
        (160.0 / 255.0, 82.0 / 255.0, 45.0 / 255.0),
        (1.0, 102.0 / 255.0, 0),
        (1.0, 1.0, 0),
        (1.0, 1.0, 1.0),
        ]
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func getColorFromArray() -> [CGColor] {
        var colorsArray = [CGColor]()
        for index in 0 ..< colorFloatsArray.count {
            let colorFloats = colorFloatsArray[index]
            let color = UIColor.init(red: colorFloats.0, green: colorFloats.1, blue: colorFloats.2, alpha: 1.0)
            colorsArray.append(color.cgColor)
        }
        return colorsArray
    }
    func addShadow(inputView:UIView){
        let shadowPath = UIBezierPath(rect: CGRect(x: 0,
                                                   y: 0,
                                                   width: inputView.frame.size.width,
                                                   height: inputView.frame.size.height))
        inputView.layer.masksToBounds = false
        inputView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        inputView.layer.shadowOpacity = 0.6
        inputView.layer.shadowPath = shadowPath.cgPath
        inputView.layer.shadowColor = UIColor.darkGray.cgColor
        inputView.layer.shadowRadius = 4
        inputView.layer.cornerRadius = 4
    }

}

