//
//  FriendTableViewCell.swift
//  Challenger
//
//  Created by SongXujie on 23/12/2015.
//  Copyright © 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation
import Contacts

protocol FriendTableViewCellProtocol {
    func selectedContact(contact: CNContact);
}

class FriendTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userProfileImage: AVImageView!
    @IBOutlet weak var userProfileName: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
    
    var contact: CNContact!
    var friendContact: CLUser!
    
    var delegate: FriendTableViewCellProtocol?
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)!
    }
    
    @IBAction func inviteButtonClicked(sender: UIButton) {
        if (sender.titleForState(.Normal) == "Invite"){
            self.delegate?.selectedContact(self.contact);
        } else if (sender.titleForState(.Normal) == "Follow") {
             CL.currentUser.follow(friendContact.objectId, andCallback: { (success, error) -> Void in
                if let _ = error {
                    //Do not show error
                } else {
                    //Do nothing
                }
            })
            self.inviteButton.setTitle("Followed", forState: .Normal);
        } else if (sender.titleForState(.Normal) == "Followed") {
            //Perform friend unfollow
            CL.currentUser.unfollow(friendContact.objectId, andCallback: { (success, error) -> Void in
                if let _ = error {
                    //Do not show error
                } else {
                    //Do nothing
                }
            })
            self.inviteButton.setTitle("Follow", forState: .Normal);
        }
        
    }
    
    func reloadPhoneContact(contact: CNContact) {
        self.contact = contact;
        self.inviteButton.setTitle("Invite", forState: .Normal);
//        if let data = self.contact.imageData {
//            self.userProfileImage.image = UIImage(data: data);
//        }
        self.userProfileName.text = self.contact.givenName + " " + self.contact.familyName;
    }
    
    //Load facebook friends info
    func reloadFBContact (facebookContact: CLUser, followeeArray: [String]) {
        
        for followee in followeeArray {
            if (followee == facebookContact.objectId){
                self.inviteButton.setTitle("Followed", forState: .Normal);
                break;
            } else {
                self.inviteButton.setTitle("Follow", forState: .Normal);
            }
        }
        
        //self.inviteButton.setTitle("Follow", forState: .Normal);
        self.friendContact = facebookContact;
        
        //Get user profile image
        
//        self.fbFriendID = facebookContact.fbId;
        
//        let pictureURL = "https://graph.facebook.com/\(self.fbFriendID!)/picture?type=small&return_ssl_resources=1";
//        let URLRequest = NSURL(string: pictureURL);
//        let URLRequestNeeded = NSURLRequest(URL: URLRequest!);
//        NSLog("PictureURL: \(pictureURL)");
//        
//        NSURLConnection.sendAsynchronousRequest(URLRequestNeeded, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
//            if (error != nil){
//                NSLog("Error downloading profile image");
//                NSLog("\(error)");
//            } else if let profileImage = UIImage(data: data!) {
//                self.userProfileImage.image = profileImage;
//            }
//        }
        self.userProfileImage.file = facebookContact.profileImage;
        self.userProfileImage.loadInBackground();
        
        self.userProfileName.text = facebookContact.profileName;
        

        NSLog("Contact: \(facebookContact)");
        
        
        
    }
}