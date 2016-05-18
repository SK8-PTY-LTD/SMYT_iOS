//
//  FindFriendsViewController.swift
//  Challenger
//
//  Created by SongXujie on 23/12/2015.
//  Copyright © 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation
import Contacts
import MessageUI

class FindFriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate, FriendTableViewCellProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    
    var isFacebookSelected: Bool = false;
    
    var phoneContactList = [CNContact]();
    var facebookFriendsArray = [CLUser]();
    
    var followeeIdArray = [String]();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        fetchContactInfo();
        fetchFollowerInfo();
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (isFacebookSelected){
            NSLog("number of friends: \(self.facebookFriendsArray.count)");
            return self.facebookFriendsArray.count;
        } else {
            NSLog("number of phone contacts: \(self.phoneContactList.count)");
            return self.phoneContactList.count;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //If facebook button is selected
        if (isFacebookSelected){
            let cell = self.tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as! FriendTableViewCell;
            cell.delegate = self;
            cell.inviteButton.layer.borderColor = UIColor(red: 70, green: 158, blue: 157).CGColor;
            cell.userProfileImage.image = UIImage(named: "AppIcon");
            cell.reloadFBContact(self.facebookFriendsArray[indexPath.row] , followeeArray: followeeIdArray);
            return cell;
            
        //If phone contact button is selected
        } else {
            let cell = self.tableView.dequeueReusableCellWithIdentifier("contactCell", forIndexPath: indexPath) as! FriendTableViewCell;
            cell.delegate = self;
            cell.inviteButton.layer.borderColor = UIColor(red: 70, green: 158, blue: 157).CGColor;
            cell.userProfileImage.image = UIImage(named: "AppIcon");
            cell.reloadPhoneContact(self.phoneContactList[indexPath.row]);
            return cell;
        }
    }
    
    func selectedContact(contact: CNContact) {
        let controller = MFMessageComposeViewController();
        if (MFMessageComposeViewController.canSendText()) {
            controller.body = "Hi \(contact.givenName)! Join me and Challenge me!"
//            controller.recipients = contact.phoneNumbers[0].value as! [String];
            controller.messageComposeDelegate = self;
            self.presentViewController(controller, animated: true, completion: { () -> Void in
                
            });
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        if (result == MessageComposeResultCancelled){
            NSLog("Message cancelled");
        }
        else if (result == MessageComposeResultSent){
            NSLog("Message sent");
        }
        else{
            NSLog("Message failed");
        }
        controller.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        });
    }
    
    
    @IBAction func contactButtonClicked(sender: AnyObject) {
        fetchContactInfo();
        isFacebookSelected = false;
        NSLog("Phone contact selected");
        self.tableView.reloadData();
    }
    
    @IBAction func faceBookButtonClicked(sender: AnyObject) {
        
        //Get facebook friends
        NSLog("Current Token is \(FBSDKAccessToken.currentAccessToken())");
        FBSDKGraphRequest(graphPath: "/me/friends", parameters: ["fields":"name,email"], HTTPMethod: "GET").startWithCompletionHandler { (connection, result, error) -> Void in
            
            //Download and parse friends data
            if (error != nil) {
                NSLog("Error while downloading user friends data from facebook.com");
            } else if let userFriendsArray = result["data"] as? NSArray {
                var fbIdArray = [String]();
                for (var i=0; i<userFriendsArray.count; i++) {
                    let fbUser = userFriendsArray[i] as! [NSObject: AnyObject];
                    let fbId = fbUser["id"] as! String;
                    fbIdArray.append(fbId);
                }
                
                var facebookFriendsArray = CLUser.query();
                facebookFriendsArray.whereKey("fbId", containedIn: fbIdArray);
                facebookFriendsArray.findObjectsInBackgroundWithBlock({ (downloadArray, error) -> Void in
                    if let e = error {
                        CL.showError(e);
                    } else {
                        self.facebookFriendsArray = downloadArray as! [CLUser];
                        self.tableView.reloadData();
                    }
                });
            }
        }
        isFacebookSelected = true;
        NSLog("Facebook selected");
    }
    
    func fetchContactInfo() {
        let contactStore = CNContactStore()
        self.phoneContactList = [];
        do {
            let request:CNContactFetchRequest
            request = CNContactFetchRequest(keysToFetch: [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactMiddleNameKey, CNContactEmailAddressesKey,CNContactPhoneNumbersKey])
            request.sortOrder = CNContactSortOrder.FamilyName
            try contactStore.enumerateContactsWithFetchRequest(request) {
                (contact, cursor) -> Void in
                self.phoneContactList.append(contact)
            }
        }
        catch{
            print("Handle the error please")
        }
        self.tableView.reloadData();
    }
    
    func fetchFollowerInfo() {
        let query = CL.currentUser.followeeQuery();
        query.findObjectsInBackgroundWithBlock { (downloadArray, error) -> Void in
            if let e = error {
                //Do nothing
            } else {
                //Cast download array to CLUser array
                for (var i=0; i<downloadArray.count; i++) {
                    let followee = downloadArray[i];
                    self.followeeIdArray.append(followee.objectId);
                }
            }
        }
    }
}