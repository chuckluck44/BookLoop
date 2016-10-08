//
//  AppDelegate.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 8/25/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit
import Parse
import SVProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Parse configuration
        
        let configuration = ParseClientConfiguration {
            $0.applicationId = "0000.bookloop"
            $0.server = "http://localhost:1337/parse"
        }
        Parse.initializeWithConfiguration(configuration)
        
        // Initial view setup
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        if PFUser.currentUser() == nil {
            let loginStoryboard = UIStoryboard(name: "Login", bundle: nil)
            let initialViewController = loginStoryboard.instantiateInitialViewController()
            self.window!.rootViewController = initialViewController;
        } else {
            let menuStoryboard = UIStoryboard(name: "Menu", bundle: nil)
            let initialViewController = menuStoryboard.instantiateInitialViewController()
            self.window!.rootViewController = initialViewController;
        }
        
        self.window!.makeKeyAndVisible()
        
        /*
        PFCloud.callFunctionInBackground("textbookMatchingISBN", withParameters: ["isbn":"0078024269"]) {
            (response: AnyObject?, error: NSError?) -> Void in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print(response as! PFObject)
            }
        }
        
        
        let trade = PFObject(className: "TradeGroup")
        trade["users"] = [(PFUser.currentUser()!),(PFObject(withoutDataWithClassName: "_User", objectId: "jP57Xnd6aP"))]
         do { try trade.save() }
         catch { print("ERROR") }
        */
        
        
        SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.Dark)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

