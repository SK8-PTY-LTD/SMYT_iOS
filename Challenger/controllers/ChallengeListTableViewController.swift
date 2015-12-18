//
//  ChallengeListTableViewController.swift
//  Challenger
//
//  Created by SongXujie on 15/12/2015.
//  Copyright © 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

class ChallengeListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var challengeList = ["8-ball challenge", "Watermelon hoop challenge", "Spinning coin challenge", "Tossing egg challenge"]
    
    override func viewDidLoad() {
        super.viewDidLoad();
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCellWithIdentifier("challengeCell", forIndexPath: indexPath);
        cell.textLabel?.text = "\(indexPath.row + 1). \(self.challengeList[indexPath.row])";
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("segueToUpload", sender: nil);
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "segueToUpload") {
            //            var VC = segue.destinationViewController as! UploadViewController;
        }
    }

}