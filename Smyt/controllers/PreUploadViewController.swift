//
//  PreUploadViewController.swift
//  Smyt
//
//  Created by Shawn on 4/05/2016.
//  Copyright © 2016 SK8 PTY LTD. All rights reserved.
//

import UIKit

class PreUploadViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    var challengeArray = [CLChallenge]();
    var selectedChallenge: CLChallenge?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true);
        self.navigationController?.navigationBar.hidden = false;
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.hidden = true;
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return challengeArray.count;
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UIScreen.mainScreen().bounds.width/2;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let challenge = self.challengeArray[indexPath.row];
        // Configure the cell...
        let cellIdentifier = "categoryTableViewCell";
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! CategoryTableViewCell;
        
        cell.categoryTitleLabel.text = "\(challenge.name)";
        if let urlString = challenge.coverImage.url {
            cell.backgroundImageView.sd_setImageWithURL(NSURL(string: urlString)) { (image, error, cacheType, url) in
                //do nothing yet
            }
        } else {
            cell.backgroundImageView.image = UIImage();
        }
        
        
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        self.selectedChallenge = self.challengeArray[indexPath.row];
        self.performSegueWithIdentifier("segueToVideoCapture", sender: self.selectedChallenge);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "segueToVideoCapture") {
            let vc = segue.destinationViewController as! VideoCaptureViewController;
            vc.challenge = sender as! CLChallenge;
        }
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    
}
