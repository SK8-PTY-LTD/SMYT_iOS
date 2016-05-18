//
//  CommentsViewController.swift
//  Challenger
//
//  Created by SongXujie on 7/01/2016.
//  Copyright © 2016 SK8 PTY LTD. All rights reserved.
//

import Foundation

class CommentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate/*, CommentTableViewCellProtocol*/ {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentView: UIView!
    
//    @IBOutlet weak var tableviewHightConstraint: NSLayoutConstraint!

    var video: CLVideo!
    var commentsArray = [CLComment]()
    var refreshControl = UIRefreshControl();
    
    var keyboardHeight: CGFloat = 80.0;
    var hasChanged = false;
    
    override func viewDidLoad() {
        
//        self.tableviewHightConstraint.constant = UIScreen.mainScreen().bounds.height - (self.tabBarController?.tabBar.frame.height)! - (self.navigationController?.navigationBar.frame.height)! - UIApplication.sharedApplication().statusBarFrame.height - 54;
        self.tableView.setNeedsLayout();
        NSLog("tabbar: \(self.tabBarController?.tabBar.frame.height)");
        NSLog("navbar: \(self.navigationController?.navigationBar.frame.height)");
        
        //Added keyboard observer
//        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillAppear:", name:UIKeyboardWillShowNotification, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector:"keyboardWillDisappear:", name:UIKeyboardWillHideNotification, object: nil)
        
        self.reloadComments();
        
        self.refreshControl.backgroundColor = UIColor.whiteColor();
        self.refreshControl.tintColor = UIColor.cyanColor();
        self.refreshControl.addTarget(self, action: Selector("reloadComments"), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl);
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blackColor()];
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated);
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    func reloadComments() {
        
        var query = CLComment.query();
        query.whereKey("video", equalTo: self.video);
        query.orderByAscending("createdAt");
        query.limit = 25;
        query.includeKey("sender");
        query.findObjectsInBackgroundWithBlock { (downloadArray, error) -> Void in
            if let e = error {
                CL.showError(e);
            } else {
                NSLog("Comment donwloaded \(downloadArray)");
                self.commentsArray = downloadArray as! [CLComment];
                self.tableView.reloadData();
                self.refreshControl.endRefreshing();
            }
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentsArray.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath) as! CommentTableViewCell;
        cell.comment = self.commentsArray[indexPath.row] as! CLComment;
        //cell.delegate = self;
        cell.loadComment();
        return cell;
    }
    
    @IBAction func sendButtonClicked(button: UIButton) {
        self.textField.resignFirstResponder();
        let message = self.textField.text;
        if (message == "" || message == nil) {
            CL.promote("Please send a non-empty message");
        } else {
            var comment = CLComment(sender: CL.currentUser, video: video, text: self.textField.text!);
            self.textField.text = "";
            comment.saveInBackgroundWithBlock { (success, error) -> Void in
                if let e = error {
                    //Comment failed to sent
                } else {
                    self.newCommentSent();
                    self.reloadComments();
                }
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.textField.resignFirstResponder();
        return true;
    }
    
    func newCommentSent() {
        self.video.incrementKey("numberOfComment");
        self.video.saveInBackground();
        
        //Send push
        let pushQuery = AVInstallation.query();
        
        pushQuery.whereKey("userId", equalTo: self.video.owner?.objectId);
        if let name = CL.currentUser["profileName"] as? String {
            let data = ["type" : "2",
                        "alert" : name + " has commented on your video",
                        "videoID" : self.video.objectId];
            CL.sendPush(pushQuery, data: data);
        } else {
            let data = ["type" : "2",
                       "alert" : "Someone has commented on your video"];
            CL.sendPush(pushQuery, data: data);
        }
    }
    
    //Observe method for showing keyboard
    func keyboardWillAppear (notification: NSNotification){
        
        NSLog("Showing keyboard");
        let userInfo = notification.userInfo;
        
        //Get Keyboard information
        let keyBoardSize = (userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue().size;
        self.keyboardHeight = keyBoardSize.height;
        NSLog("Keyboard height: \(self.keyboardHeight)");
        
//        let duration = (userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue;
//        NSLog("Duration \(duration)");
        
        //let contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardHeight, 0.0);
        //self.commentView.contentInset = contentInsets;
        //self.tableView.scrollIndicatorInsets = contentInsets;
        //NSLog("Origin Y was \(self.commentView.frame.origin.y)");
        self.tableView.hidden = true;
        var messageFrame = self.commentView.frame;
        messageFrame.origin.y -= keyboardHeight;
        self.commentView.frame = messageFrame;
        NSLog("Frame is now \(self.commentView.frame)");
    }
    
    func keyboardWillDisappear (notification: NSNotification) {
        
        NSLog("Hiding keyboard");
        let userInfo = notification.userInfo;
        
        //Get Keyboard information
        let keyBoardSize = (userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue().size;
        self.keyboardHeight = keyBoardSize.height;
        NSLog("Keyboard height: \(self.keyboardHeight)");
        
        UIView.beginAnimations(nil, context: nil);
        UIView.setAnimationDuration(0.25);
        //self.tableView.contentInset = UIEdgeInsetsZero;
        UIView.commitAnimations();
        
        //self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
        
        var messageFrame = self.commentView.frame;
        messageFrame.origin.y += keyboardHeight;
        self.commentView.frame = messageFrame;
        NSLog("Frame is now \(self.commentView.frame)");
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true);
    }
    
    
    
    
}
