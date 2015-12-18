//
//  TabViewController.swift
//  PicQurate
//
//  Created by SongXujie on 26/04/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

class TabViewController: UITabBarController {
    
    override func viewWillAppear(animated: Bool) {
        let button = UIButton()
        let buttonImage = UIImage(named: "tab_camera_0");
        button.frame = CGRectMake(0.0, 0.0, self.tabBar.frame.width/5, self.tabBar.frame.height);
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
    }
    
    func cameraButtonClicked() {
        if (CL.currentUser != nil && CL.currentUser.email != nil) {
            self.performSegueWithIdentifier("segueToChallengeList", sender: nil);
        } else {
            self.performSegueWithIdentifier("segueToLogin", sender: nil);
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "segueToChallengeList") {
//            var VC = segue.destinationViewController as! UploadViewController;
        }
    }
    
    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if (CL.currentUser != nil && CL.currentUser.email != nil) {
            //User logged in, do nothing
        } else {
            if (item.image != UIImage(named: "tab_home_0")) {
                self.performSegueWithIdentifier("segueToLogin", sender: nil);
            }
        }
    }
    
    
}
