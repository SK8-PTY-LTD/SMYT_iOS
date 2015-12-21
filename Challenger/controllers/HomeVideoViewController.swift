//
//  HomeVideoViewController.swift
//  Challenger
//
//  Created by SongXujie on 19/12/2015.
//  Copyright © 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

class HomeVideoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, HomeVideoTableViewCellProtocol {
    
    @IBOutlet weak var tabNewButton: UIButton!
    @IBOutlet weak var tabPopularButton: UIButton!
    @IBOutlet weak var tabFailButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var videoArray = [CLVideo]();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        reloadVideos(self.tabNewButton);
    }
    
    @IBAction func reloadVideos(sender: UIButton) {
        
        var query = CLVideo.query();
        query.includeKey("challenge");
        query.includeKey("owner");
        query.whereKey("status", equalTo: CLVideo.STATUS.LISTING);
        
        if (sender == self.tabNewButton) {
            self.tabNewButton.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 17.0);
            self.tabPopularButton.titleLabel?.font = UIFont(name: "Helvetica", size: 17.0);
            self.tabFailButton.titleLabel?.font = UIFont(name: "Helvetica", size: 17.0);
            
            query.orderByDescending("createdAt");
            query.whereKey("isSuccessVideo", equalTo: true);
            
        } else if (sender == self.tabPopularButton) {
            self.tabNewButton.titleLabel?.font = UIFont(name: "Helvetica", size: 17.0);
            self.tabPopularButton.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 17.0);
            self.tabFailButton.titleLabel?.font = UIFont(name: "Helvetica", size: 17.0);
            
            query.orderByDescending("numberOfVerify");
            query.whereKey("isSuccessVideo", equalTo: true);
            
        } else if (sender == self.tabFailButton) {
            self.tabNewButton.titleLabel?.font = UIFont(name: "Helvetica", size: 17.0);
            self.tabPopularButton.titleLabel?.font = UIFont(name: "Helvetica", size: 17.0);
            self.tabFailButton.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 17.0);
            
            query.orderByDescending("createdAt");
            query.whereKey("isSuccessVideo", equalTo: false);
            
        }
        
        query.findObjectsInBackgroundWithBlock { (downloadArray, error) -> Void in
            if let e = error {
                CL.showError(e);
            } else {
                self.videoArray = downloadArray as! [CLVideo];
                self.tableView.reloadData();
                NSLog("\(self.tableView.frame)");
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.videoArray.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("videoTableViewCell", forIndexPath: indexPath) as! HomeVideoTableViewCell;
        cell.video = self.videoArray[indexPath.row];
        cell.delegate = self;
        cell.invalidateIntrinsicContentSize();
        //Play the first video
//        if (indexPath.row == 0) {
//            cell.videoPlayer.play();
//        }
        return cell;
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //Moved out of table view, stop video from playing
        (cell as! HomeVideoTableViewCell).videoPlayer.pause();
        
        //First check if previous cell had become available
        let previousIndexPath = NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section);
        let previousCell = self.tableView.cellForRowAtIndexPath(previousIndexPath) as? HomeVideoTableViewCell;
        if (previousCell?.window != nil) {
            //Scrolled up
            NSLog("Playing \(previousIndexPath.row)");
            previousCell!.videoPlayer.play();
        } else {
            //Scrolled down
            let nextIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section);
            let nextCell = self.tableView.cellForRowAtIndexPath(nextIndexPath) as! HomeVideoTableViewCell;
            NSLog("Playing \(nextIndexPath.row)");
            nextCell.videoPlayer.play();
        }
        
        var video = (cell as! HomeVideoTableViewCell).video;
        
        
    }
    
    //Delegate method for HomeVideoTableViewCellProtocol
    func presentViewController(VC: UIViewController) {
        
        //For iOS 8
        VC.providesPresentationContextTransitionStyle = true;
        VC.definesPresentationContext = true;
        VC.modalPresentationStyle = UIModalPresentationStyle.CurrentContext;
        self.presentViewController(VC, animated: true, completion: nil);
        
    }
    
}