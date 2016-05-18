//
//  AppDelegate.swift
//  Challenger
//
//  Created by SongXujie on 1/12/2015.
//  Copyright © 2015 SK8 PTY LTD. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import NSDate_Time_Ago

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //Initialize AVOSCloud
        CL.initialize(launchOptions);
        
        //Register for push notification
        if (UIDevice.currentDevice().systemVersion.floatValue < 8.0) {
            // iOS 8 Notifications
            NSLog("IOS<8");
            let types: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
            let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
            application.registerUserNotificationSettings(settings);
            application.registerForRemoteNotifications();
        } else {
            // iOS < 8 Notifications
            NSLog("IOS>=8");
            let types: UIUserNotificationType = [UIUserNotificationType.Badge, UIUserNotificationType.Sound, UIUserNotificationType.Alert]
            let settings = UIUserNotificationSettings(forTypes: types, categories: nil);
            application.registerUserNotificationSettings(settings);
            application.registerForRemoteNotifications();
        }
        //AVPush.setProductionMode(false);
        
        //Facebook Iniitalizing code
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions);
        
//        let type = "2";
//        if (type == "2"){
//            //Get video ID
//            
//            
//            //Commented - comment
//            let rootVC = self.window?.rootViewController as! TabViewController;
//            //let navVC = self.window?.rootViewController?.navigationController;
//            //let storyboard = UIStoryboard(name: "Profile", bundle: nil);
//            //let vc = storyboard.instantiateViewControllerWithIdentifier("ProfileVC") as! ProfileViewController;
//            rootVC.selectedIndex = 0;
//            let navVC = rootVC.selectedViewController as! UINavigationController;
//            navVC.viewWillAppear(true);
//            let currentVC = navVC.topViewController as! HomeVideoViewController;
//            
//            let video = CLVideo(videoId: notificationPayload["videoID"] as! String);
//            currentVC.performSegueWithIdentifier("segueToCommentsViewController", sender: video);
//            //navVC.pushViewController(vc, animated: true);
////            rootVC.presentViewController(vc, animated: true, completion: nil);
////            rootVC.showViewController(vc, sender: nil);
//        }
        
        if let options = launchOptions {
            let notificationPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey];
            let type = notificationPayload!["type"] as! String ;
            
            if (type == "1"){
                NSLog("type 1, going profile");
                //liked - go to profile
                let rootVC = self.window?.rootViewController as! TabViewController;
                rootVC.selectedIndex = 4;
                let navVC = rootVC.selectedViewController as! UINavigationController;
                navVC.viewWillAppear(true);
            }
            
            if (type == "2"){
                //Commented - comment
                NSLog("type 2, videoID \(notificationPayload!["videoID"] as! String), going comment");
                let rootVC = self.window?.rootViewController as! TabViewController;
                rootVC.selectedIndex = 0;
                let navVC = rootVC.selectedViewController as! UINavigationController;
                navVC.viewWillAppear(true);
                let currentVC = navVC.topViewController as! HomeVideoViewController;
                
                let video = CLVideo(videoId: notificationPayload!["videoID"] as! String);
                currentVC.performSegueWithIdentifier("segueToCommentsViewController", sender: video);
            }
            
            if (type == "3"){
                //Followed - all followers
                NSLog("type 3, going followers");
                let rootVC = self.window?.rootViewController as! TabViewController;
                rootVC.selectedIndex = 4;
                let navVC = rootVC.selectedViewController as! UINavigationController;
                navVC.viewWillAppear(true);
                let currentVC = navVC.topViewController as! ProfileViewController;
                currentVC.followerButtonClicked();
            }
        }
        
        
        return true;
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
        FBSDKAppEvents.activateApp();
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation);
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = AVInstallation.currentInstallation();
        installation.setDeviceTokenFromData(deviceToken);
        installation.saveInBackground();
        NSLog("Saving installation deviceToken: \(deviceToken)");
        //        if (CL.currentUser != nil && CL.currentUser.email != nil) {
//            let installation = AVInstallation.currentInstallation();
//            installation.setDeviceTokenFromData(deviceToken);
//            installation.setObject(CL.currentUser.objectId, forKey: "userId");
//            installation.saveInBackgroundWithBlock({ (success, error) -> Void in
//                if (success) {
//                    CL.currentUser.setInstallation(installation);
//                    CL.currentUser.saveInBackground();
//                } else {
//                    CL.showError(error);
//                }
//            });
//        }
    }
}

