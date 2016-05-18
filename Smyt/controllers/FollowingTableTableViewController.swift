//
//  FollowingTableTableViewController.swift
//  Challenger
//
//  Created by Shaoxuan Shen on 16/1/12.
//  Copyright © 2016年 SK8 PTY LTD. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import FBSDKShareKit

class FollowingTableTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FollowingTableViewProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    
    var userToDisplay: CLUser!
    var refreshControl = UIRefreshControl();
    var friendArray = [CLUser]();
    var isFollowing = true;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
//        var searchBar = UISearchBar.init();
//        var searchController = UISearchDisplayController.init(searchBar: searchBar, contentsController: self);
        //searchController.delegate = self;
        //searchController.searchResultsDataSource = self;
//        self.tableView.tableHeaderView = searchBar;
        //NSLog("search bar height \(CGRectGetHeight(self.searchBar.frame))")
        //self.tableView.contentOffset = CGPointMake(0, -CGRectGetHeight(self.searchBar.frame));
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.refreshControl.backgroundColor = UIColor.whiteColor();
        self.refreshControl.tintColor = UIColor.cyanColor();
        self.refreshControl.addTarget(self, action: Selector("reloadUser"), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true);
        NSLog("following view appeared");
        self.reloadFriend();
    }
    
    func reloadFriend() {
        if (isFollowing){
            NSLog("reloading following");
            self.reloadFollowing();
        } else {
            NSLog("reloading followee");
            self.reloadFollower();
        }
    }
    
    func reloadFollowing() {
        
        if let query = AVUser.followeeQuery(self.userToDisplay.objectId){
            query.findObjectsInBackgroundWithBlock { (downloadArray, error) -> Void in
                if let e = error {
                    CL.showError(e);
                } else {
                    NSLog("download array\(downloadArray)");
                    self.friendArray = downloadArray as! [CLUser];
                    self.friendArray.sortInPlace({ (followee1, followee2) -> Bool in
                        followee1.level > followee2.level;
                    })
                    self.tableView.reloadData();
                }
            }
        }
        
        self.refreshControl.endRefreshing();
    }
    
    func reloadFollower() {
        
        let query = AVUser.followerQuery(self.userToDisplay.objectId);
        NSLog("user to display: \(self.userToDisplay.objectId)");
        //query.cachePolicy =  .NetworkElseCache;
        query.findObjectsInBackgroundWithBlock { (downloadArray, error) -> Void in
            if let e = error {
                CL.showError(e);
            } else {
                //sort by level
                self.friendArray = downloadArray as! [CLUser]
                NSLog("friend array: \(self.friendArray)");
                self.friendArray.sortInPlace({ (follower1, follower2) -> Bool in
                    follower1.level > follower2.level;
                })
                self.tableView.reloadData();
            }
        }
        
        self.refreshControl.endRefreshing();
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1;
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.friendArray.count;
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        // Configure the cell...
        
        let cellIdentifier = "followingTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! FollowingTableViewCell
        cell.delegate = self;
        
        let friendToDisplay = self.friendArray[indexPath.row];
        
        cell.userToDisplay = friendToDisplay;
        cell.followerProfileImageView.file = friendToDisplay.profileImage;
        cell.followerProfileImageView.loadInBackground();
        cell.profileNameLabel.text = friendToDisplay.profileName;
        cell.usernameLabel.text = friendToDisplay.username;
        
        self.setFollowingButton(friendToDisplay, button: cell.followButton);
        
        //Following's follow button is always "Unfollow"
        if (self.userToDisplay == CL.currentUser){
            if (!self.isFollowing){
                self.setFollowingButton(friendToDisplay, button: cell.followButton);
            }
        } else {
            cell.followButton.hidden = true;
        }
        
        
        return cell;
    }
    
    func followButtonClicked(cell: FollowingTableViewCell) {
        if (self.isFollowing){
            CL.currentUser.unfollow(cell.userToDisplay.objectId, andCallback: { (success, error) -> Void in
                if (success){
                    if let index  = self.friendArray.indexOf(cell.userToDisplay){
                        self.friendArray.removeAtIndex(index);
                        self.tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Left);
                        CL.promote("Unfollow successful");
                    }
                }
            });
        } else {
            if (cell.followButton.currentTitle == "Follow"){
                CL.currentUser.follow(cell.userToDisplay.objectId, andCallback: { (success, error) -> Void in
                    if (success){
                        self.setButtonAsUnfollow(cell.followButton);
                        CL.promote("Follow successful");
                        
                        //Send push
                        let pushQuery = AVInstallation.query();
                        pushQuery.whereKey("userId", equalTo: cell.userToDisplay.objectId);
                        if let name = CL.currentUser["profileName"] as? String {
                            let data = ["type" : "3",
                                "alert" : name + " is now following you."];
                            CL.sendPush(pushQuery, data: data);
                        } else {
                            let data = ["type" : "3",
                                "alert" : "You have a new follower."];
                            CL.sendPush(pushQuery, data: data);
                        }
                    }
                });
            } else {
                CL.currentUser.unfollow(cell.userToDisplay.objectId, andCallback: { (success, error) -> Void in
                    if (success){
                        self.setButtonAsFollow(cell.followButton);
                        CL.promote("Unfollow successful");
                    }
                });
            }
        }
        
    }
    
    func setFollowingButton(targetUser: CLUser, button: UIButton) {
        let query = CL.currentUser.followeeQuery();
        query.whereKey("followee", equalTo: targetUser);
        
        query.findObjectsInBackgroundWithBlock { (downloadArray, error) -> Void in
            if let e = error {
                CL.showError(e);
            } else {
                if (downloadArray.count == 0){
                    //not followee
                    self.setButtonAsFollow(button);
                } else {
                    self.setButtonAsUnfollow(button);
                }
            }
        }
    }
    
    func setButtonAsFollow(button: UIButton) {
        button.setTitle("Follow", forState: .Normal);
        button.setTitleColor(UIColor.whiteColor(), forState:.Normal);
        button.backgroundColor = UIColor.init(hex: "CC0000");
        button.layer.borderWidth = 0;
        
    }
    
    func setButtonAsUnfollow(button: UIButton) {
        button.setTitle("Unfollow", forState: .Normal);
        button.setTitleColor(UIColor.darkGrayColor(), forState:.Normal);
        button.backgroundColor = UIColor.clearColor();
        button.layer.borderWidth = 1.0;
        button.layer.borderColor = UIColor.init(hex: "C1C1C1").CGColor;
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true);
    }
}
