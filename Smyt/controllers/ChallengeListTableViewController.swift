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
    
    var challengeArray = [CLChallenge]();
    var selectedChallenge: CLChallenge?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        let query = CLChallenge.query();
        query.orderByAscending("serial");
        query.findObjectsInBackgroundWithBlock { (challengeArray, error) -> Void in
            if let e = error {
                CL.showError(e);
            } else {
                self.challengeArray = challengeArray as! [CLChallenge];
                self.tableView.reloadData();
            }
        }
    }
    
    @IBAction func closeButtonClicked(sender: UIButton) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return challengeArray.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("challengeCell", forIndexPath: indexPath);
        cell.textLabel?.text = "\(indexPath.row + 1). \(self.challengeArray[indexPath.row].name)";
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedChallenge = self.challengeArray[indexPath.row];
        self.performSegueWithIdentifier("segueToChallengeDetail", sender: nil);
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "segueToChallengeDetail") {
            let VC = segue.destinationViewController as! ChallengeDetailViewController;
            VC.challenge = self.selectedChallenge!;
        }
    }

}