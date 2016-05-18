//
//  FriendsPagingViewController.swift
//  Challenger
//
//  Created by SongXujie on 6/04/2016.
//  Copyright © 2016 SK8 PTY LTD. All rights reserved.
//

import UIKit
import PagingMenuController

class FriendsPagingViewController: UIViewController, PagingMenuControllerDelegate {
    
    var pagingMenuController: PagingMenuController!

    override func viewDidLoad() {
        super.viewDidLoad()

        //self.navigationController?.navigationBar.hidden = true;
        
        let followingVC = self.storyboard?.instantiateViewControllerWithIdentifier("followingViewController") as! FollowingTableTableViewController;
        let followeeVC = self.storyboard?.instantiateViewControllerWithIdentifier("followeeViewController") as! FollowingTableTableViewController;
        let notificationVC = self.storyboard?.instantiateViewControllerWithIdentifier("notificationViewController") as! NotificationTableViewController;
        
        let viewControllers = [followingVC, followeeVC, notificationVC];
        
        let options = PagingMenuOptions();
        options.menuHeight = 40;
        options.menuDisplayMode = .SegmentedControl;
        self.pagingMenuController = self.childViewControllers.first as! PagingMenuController
        self.pagingMenuController.delegate = self
        self.pagingMenuController.setup(viewControllers: viewControllers, options: options)
    }
    
    func didMoveToPageMenuController(menuController: UIViewController, previousMenuController: UIViewController) {
        self.navigationController?.navigationItem.title = "menuController.title";
        if (menuController.title == "Following"){
            let vc = menuController as! FollowingTableTableViewController;
            vc.isFollowing = true;
            vc.reloadFriend();
        } else if (menuController.title == "Followee"){
            let vc = menuController as! FollowingTableTableViewController;
            vc.isFollowing = false;
            vc.reloadFriend();
        } else if (menuController.title == "Notification"){
            let vc = menuController as! NotificationTableViewController;
            vc.reloadPushNotification();
        }
    }
    
    

}
