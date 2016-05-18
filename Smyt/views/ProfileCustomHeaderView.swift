//
//  ProfileCustomHeaderView.swift
//  Challenger
//
//  Created by Shawn on 4/13/16.
//  Copyright © 2016 SK8 PTY LTD. All rights reserved.
//

import UIKit
import Toucan

protocol ProfileCustomHeaderViewProtocol {
    
    func followerButtonClicked();
    func followingButtonClicked();
    
}

class ProfileCustomHeaderView: UIView {

    @IBOutlet var headerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var followButton: UIButton?
    
    var userToDisplay: CLUser!
    var delegate: ProfileCustomHeaderViewProtocol!
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        self.frame = UIScreen.mainScreen().bounds;
        NSBundle.mainBundle().loadNibNamed("ProfileCustomHeaderView", owner: self, options: nil);
        self.headerView.frame = UIScreen.mainScreen().bounds;
        self.addSubview(self.headerView);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
    func initWithUser(user: CLUser) {
        
        self.userToDisplay = user;
        
        self.bioTextView.textContainer.maximumNumberOfLines = 3;
        self.bioTextView.textContainer.lineBreakMode = NSLineBreakMode.ByTruncatingTail;
        self.bioTextView.contentInset = UIEdgeInsetsMake(-5, 0, 0, 0);
        
        if let _ = self.userToDisplay {
            self.followButton?.hidden = true;
            if (self.userToDisplay == CL.currentUser){
                //currentUser - Hide follow button
                self.followButton?.hidden = true;
            } else {
                //Other user's profile - show follow button
                self.setFollowingButton(self.userToDisplay);
            }
            
            self.userNameLabel.text = self.userToDisplay.profileName;
            self.bioTextView.text = self.userToDisplay.bio;
            
            self.userToDisplay.followerQuery().countObjectsInBackgroundWithBlock { (number, error) in
                if (error != nil){
                    NSLog("Count follower error");
                } else {
                    self.followerLabel.text = String(number);
                }
            }
            
            self.userToDisplay.followeeQuery().countObjectsInBackgroundWithBlock { (number, error) in
                if (error != nil){
                    NSLog("Count followee error");
                } else {
                    self.followingLabel.text = String(number);
                }
            }
            
            if let img = self.userToDisplay.profileImage {
                self.profileImageView.sd_setImageWithURL(NSURL.init(string: img.url), placeholderImage: UIImage(named: "default_profile"), completed: { (image, error, cacheType, url) in
                    let roundedImage = Toucan(image: image).maskWithEllipse().image;
                    self.profileImageView.image = roundedImage;
                })
                
            } else {
                self.profileImageView.image = UIImage(named: "default_profile");
            }
        }   
        
    }
    
    
    @IBAction func followButtonClicked(sender: UIButton) {
        if (sender.currentTitle == "Follow"){
            CL.currentUser.follow(self.userToDisplay.objectId, andCallback: { (success, error) -> Void in
                if (success){
                    self.setButtonAsUnfollow();
                    CL.promote("Follow successful");
                    
                    //Send push
                    let pushQuery = AVInstallation.query();
                    pushQuery.whereKey("userId", equalTo: self.userToDisplay.objectId);
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
            CL.currentUser.unfollow(self.userToDisplay.objectId, andCallback: { (success, error) -> Void in
                if (success){
                    self.setButtonAsFollow();
                    CL.promote("Unfollow successful");
                }
            });
        }
    }
    
    @IBAction func followerButtonClicked(sender: UIButton) {
        self.delegate.followerButtonClicked();
    }
    
    @IBAction func followingButtonClicked(sender: UIButton) {
        self.delegate.followingButtonClicked();
    }
    
    func setFollowingButton(targetUser: CLUser) {
        let query = CL.currentUser.followeeQuery();
        query.whereKey("followee", equalTo: targetUser);
        
        query.findObjectsInBackgroundWithBlock { (downloadArray, error) -> Void in
            if let e = error {
                CL.showError(e);
            } else {
                if (downloadArray.count == 0){
                    //not followee
                    self.setButtonAsFollow()
                } else {
                    self.setButtonAsUnfollow();
                }
            }
        }
    }
    
    func setButtonAsFollow() {
        self.followButton?.setTitle("Follow", forState: .Normal);
        self.followButton?.setTitleColor(UIColor.whiteColor(), forState:.Normal);
        self.followButton?.backgroundColor = UIColor.init(hex: "CC0000");
        self.followButton?.layer.borderWidth = 0;
        self.followButton?.hidden = false;
    }
    
    func setButtonAsUnfollow() {
        self.followButton?.setTitle("Unfollow", forState: .Normal);
        self.followButton?.setTitleColor(UIColor.darkGrayColor(), forState:.Normal);
        self.followButton?.backgroundColor = UIColor.clearColor();
        self.followButton?.layer.borderWidth = 1.0;
        self.followButton?.layer.borderColor = UIColor.init(hex: "C1C1C1").CGColor;
        self.followButton?.hidden = false;
    }
    

}
