//
//  HomeVideoViewController.swift
//  Challenger
//
//  Created by SongXujie on 19/12/2015.
//  Copyright © 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

class HomeVideoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tabNewButton: UIButton!
    @IBOutlet weak var tabPopularButton: UIButton!
    @IBOutlet weak var tabFailButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var videoArray = [CLVideo]();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        
    }
    
    @IBAction func reloadVideos(sender: UIButton) {
        
        var query = CLVideo.query();
        
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
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.videoArray.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = self.tableView.dequeueReusableCellWithIdentifier("videoTableViewCell", forIndexPath: indexPath) as! HomeVideoTableViewCell;
        cell.video = self.videoArray[indexPath.row];
        cell.loadInBackground();
        return cell;
    }
    
}