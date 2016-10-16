//
//  SettingsViewController.swift
//  Challenger
//
//  Created by Shaoxuan Shen on 16/1/13.
//  Copyright © 2016年 SK8 PTY LTD. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import FBSDKShareKit
import MessageUI

protocol settingsViewProtocol {
    func selectProfileTab();
}

class SettingsViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    var delegate: settingsViewProtocol!;
    
    var settingsOptionArray1 = ["Find people", "Invite via text", "Invite via email", "Notifications", "Continuous video loading", "Facebook"];
    var settingsOptionArray2 = ["Help", "Terms of service", "Privacy policy"];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userNameLabel.text = CL.currentUser.profileName;
        self.emailLabel.text = CL.currentUser.email;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if (section == 0){
            return settingsOptionArray1.count;
        } else {
            return settingsOptionArray2.count;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Configure the cell...
        let cellIdentifier = "SettingsCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! SettingsTableViewCell;
        
        if (indexPath.section == 0){
            cell.settingNameLabel.text = settingsOptionArray1[indexPath.row];
            if (cell.settingNameLabel.text == "Facebook"){
                cell.FBStatusButton.hidden = false;
                cell.accessoryType = UITableViewCellAccessoryType.None;
                cell.selectionStyle = UITableViewCellSelectionStyle.None;
            }
            if (cell.settingNameLabel.text == "Continuous video loading"){
                cell.videoSwitch.hidden = false;
                NSLog("\(CL.isNotAutoLoading)");
                cell.videoSwitch.on = !CL.isNotAutoLoading;
                cell.accessoryType = UITableViewCellAccessoryType.None;
                cell.selectionStyle = UITableViewCellSelectionStyle.None;
            }
        } else {
            cell.settingNameLabel.text = settingsOptionArray2[indexPath.row];
            
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 1){
            return "Support"
        } else {
            return "Settings"
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        
        if (indexPath.section == 0){
            switch (indexPath.row){
            case 0:
                //jump to tab view tab No.1
                self.tabBarController?.selectedIndex = 1;
            case 1:
                //open SMS
                let controller = MFMessageComposeViewController();
                if (MFMessageComposeViewController.canSendText()) {
                    controller.body = "Hi, Join me and Challenge me!"
                    //controller.recipients = contact.phoneNumbers[0].value as! [String];
                    controller.messageComposeDelegate = self;
                    self.presentViewController(controller, animated: true, completion: { () -> Void in
                    });
                }
            case 2:
                //open email
                let controller = MFMailComposeViewController();
                controller.mailComposeDelegate = self;
                controller.setSubject("Hey there, check out CHALLENGERS!!");
                controller.setMessageBody("Hi, Join me and Challenge me!", isHTML: false);
                self.presentViewController(controller, animated: true, completion: nil);
                
            case 3:
                //jump to tab view tab No.3
                self.tabBarController?.selectedIndex = 3;
            default: break;
                //do nothing
            }
            
        } else {
            switch (indexPath.row){
            case 0:
                //jump to url
                if let helpURL:NSURL = NSURL(string:"https://www.google.com.au") {
                    let application:UIApplication = UIApplication.sharedApplication()
                    if (application.canOpenURL(helpURL)) {
                        application.openURL(helpURL);
                    }
                }
            case 1:
                //jump to url
                if let tosURL:NSURL = NSURL(string:"https://www.google.com.au") {
                    let application:UIApplication = UIApplication.sharedApplication()
                    if (application.canOpenURL(tosURL)) {
                        application.openURL(tosURL);
                    }
                }
            case 2:
                //jump to url
                if let ppURL:NSURL = NSURL(string:"https://www.google.com.au") {
                    let application:UIApplication = UIApplication.sharedApplication()
                    if (application.canOpenURL(ppURL)) {
                        application.openURL(ppURL);
                    }
                }
            default: break;
                //do nothing
            }
        }
            
            
        
    }

    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
//        if (result == MessageComposeResultCancelled){
//            NSLog("Message cancelled");
//        }
//        else if (result == MessageComposeResultSent){
//            NSLog("Message sent");
//        }
//        else{
//            NSLog("Message failed");
//        }
        controller.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        });
    }
    
    @IBAction func logoutButtonClicked(sender: AnyObject) {
        CL.currentUser = nil;
        CLUser.logOut();
        FBSDKLoginManager().logOut();
        self.delegate.selectProfileTab();
        self.navigationController?.popViewControllerAnimated(true);
        
    }

    @IBAction func backButtonClicked(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true);
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
