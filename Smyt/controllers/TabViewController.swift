//
//  TabViewController.swift
//  PicQurate
//
//  Created by SongXujie on 26/04/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

class TabViewController: UITabBarController, UITabBarControllerDelegate, landingViewProtocol {
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        //self.navigationController?.navigationBar.hidden = true;
    }
    
    override func viewWillAppear(animated: Bool) {
        NSLog("tab view will appear");
        self.tabBar.items![2].enabled = false;
        let button = UIButton()
        let buttonImage = UIImage(named: "tab_challenge");
        button.frame = CGRectMake(0.0, 0.0, self.tabBar.frame.width/6, self.tabBar.frame.width/6*0.592);
        button.setBackgroundImage(buttonImage!, forState: .Normal);
        //        button.setBackgroundImage(highlightImage!, forState: .Highlighted);
        //        [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
        
        let heightDifference = buttonImage!.size.height - self.tabBar.frame.size.height;
        if (heightDifference < 0) {
            button.center = self.tabBar.center;
        } else {
            var center = self.tabBar.center;
            center.y = center.y - heightDifference/2.0;
            button.center = center;
        }
        
        button.addTarget(self, action: "cameraButtonClicked", forControlEvents: .TouchUpInside);
        
        self.view.addSubview(button);
        
//        if (CL.currentUser == nil) {
//            NSLog("aaaaaaaaa");
//            self.performSegueWithIdentifier("segueToLogin", sender: nil);
//        }
    }
    
    func cameraButtonClicked() {
        if (CL.currentUser != nil && CL.currentUser.email != nil) {
            self.performSegueWithIdentifier("segueToVideoCapture", sender: nil);
        } else {
            self.performSegueWithIdentifier("segueToLogin", sender: nil);
            self.selectHomeTab();
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if (segue.identifier == "segueToChallengeList") {
////            var VC = segue.destinationViewController as! UploadViewController;
//        }
        
        if (segue.identifier == "segueToLogin"){
            if let vc = segue.destinationViewController as? LandingViewController{
                vc.delegate = self;
            }
        }
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if (CL.currentUser != nil && CL.currentUser.email != nil) {
            //User logged in, do nothing
            NSLog("1");
        } else {
            if (item.image != UIImage(named: "tab_home_0")) { 
                self.performSegueWithIdentifier("segueToLogin", sender: nil);
                //self.selectedIndex = 0;
            }
        }
    }
    
    func selectHomeTab(){
        self.selectedIndex = 0;
        NSLog("home selected");
    }
    
    func selectProfile() {
        self.selectedIndex = 4;
        NSLog("profile selected");
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        NSLog("going to show view: \(viewController)");
        viewController.viewWillAppear(true);
    }
    
}
