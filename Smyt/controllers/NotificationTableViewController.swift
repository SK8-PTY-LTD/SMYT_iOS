//
//  NotificationTableViewController.swift
//  Challenger
//
//  Created by SongXujie on 15/12/2015.
//  Copyright © 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation
import TTTAttributedLabel
import AFDateHelper

class NotificationTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TTTAttributedLabelDelegate, NotificationTableViewCellProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var notificationArray = [CLPush]();
    var sections = [String : [CLPush]]();
    var sectionTitleArray = [String]();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        //CL.stampTime();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true);
        
        self.notificationArray = [CLPush]();
        self.sections = [String : [CLPush]]();
        self.sectionTitleArray = [String]();
        self.tableView.reloadData();
        
//        CL.logWithTimeStamp("Start reloading notification");
        if let _ = CL.currentUser {
            self.reloadPushNotification();
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[sectionTitleArray[section]]!.count;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sectionTitleArray.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("notificationCell", forIndexPath: indexPath) as! NotificationTableViewCell;
        cell.delegate = self;
        
        //let push = self.notificationArray[indexPath.row];
        if let temp = self.sections[sectionTitleArray[indexPath.section]]{
            let push = temp[indexPath.row];
            
            if let img = push.sender.profileImage {
                cell.profileImageView.sd_setBackgroundImageWithURL(NSURL.init(string: img.url), forState: .Normal, placeholderImage: UIImage(named: "default_profile"));
            } else {
                cell.profileImageView.setBackgroundImage(UIImage(named: "default_profile"), forState: .Normal);
            }
            
            cell.notification = push;
            //Style text
            let tempString = NSMutableAttributedString(string: push.message);
            let nameLength = push.sender.profileName?.characters.count;
            tempString.addAttribute(NSFontAttributeName, value: UIFont(name: "Helvetica-Bold", size: 14.0)!, range: NSMakeRange(0, nameLength!));
            tempString.addAttribute(NSStrokeColorAttributeName, value: CL.primaryColor, range: NSMakeRange(0, nameLength!));
            cell.notificationTextView.attributedText = tempString;
        }
        
        
        return cell;
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 18;
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let dateFormatter = NSDateFormatter();
        dateFormatter.dateFormat = "dd/MM/yyyy";
        
        
        if let date = dateFormatter.dateFromString(self.sectionTitleArray[section]){
            let weekday = date.weekdayToString();
            let day = String(date.day());
            let month = date.monthToString();
            
            return weekday + " " + day + " " + month;
        } else {
            return "";
        }
        
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView;
        header.textLabel?.font = UIFont(name: "Futura", size: 9);
        header.textLabel?.textColor = UIColor.darkGrayColor();
        header.textLabel?.textAlignment = NSTextAlignment.Center;
        view.tintColor = UIColor.init(hex: "C1C1C1");
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true);
    }
    
    func userSelected(user: CLUser) {
        self.performSegueWithIdentifier("segueToProfile", sender: user);
    }
    
    func videoSelected(video: CLVideo) {
        self.performSegueWithIdentifier("segueToVideo", sender: video);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "segueToProfile"){
            let vc = segue.destinationViewController as! ViewProfileViewController;
            vc.user = sender as! CLUser;
        }
    }
    
    func reloadPushNotification() {
        self.activityIndicator.startAnimating();
        let query = CLPush.query();
        query.whereKey("user", equalTo: CL.currentUser);
        query.includeKey("sender");
        //query.includeKey("video");
        
//        CL.logWithTimeStamp("Before query");
        query.findObjectsInBackgroundWithBlock { (array, error) -> Void in
            
            self.tableView.scrollEnabled = false;
            if let e = error {
                CL.showError(e);
            } else {
                if (array != nil) {
                    //Data downloaded, sort data by date and put into dayarray
                    let dateFormatter = NSDateFormatter();
                    dateFormatter.dateFormat = "dd/MM/yyyy";
                    self.notificationArray = array as! [CLPush];
//                    CL.logWithTimeStamp("Before sort");
                    self.notificationArray.sortInPlace({ (notification1, notification2) -> Bool in
                        notification1.createdAt.compare(notification2.createdAt) == NSComparisonResult.OrderedDescending;
                    })
//                    CL.logWithTimeStamp("After sort, start arrange data by date");
                    for notifification in self.notificationArray {
                        let date = dateFormatter.stringFromDate(notifification.createdAt);
                        if (self.sections.indexForKey(date) == nil){
                            self.sections[date] = [notifification];
                            self.sectionTitleArray.append(date);
                        } else {
                            self.sections[date]?.append(notifification);
                        }
                    }
//                    CL.logWithTimeStamp("After arrange data by date");
                    self.notificationArray = array as! [CLPush];
                    self.tableView.reloadData();
                }
            }
            self.tableView.scrollEnabled = true;
            self.activityIndicator.stopAnimating();
            
        }
        
    }
}