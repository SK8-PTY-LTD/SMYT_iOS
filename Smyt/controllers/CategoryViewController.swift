//
//  CategoryViewController.swift
//  Smyt
//
//  Created by Shawn on 4/05/2016.
//  Copyright © 2016 SK8 PTY LTD. All rights reserved.
//

import UIKit
import SDWebImage

class CategoryViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewSpinner: UIActivityIndicatorView!
    
    var challengeArray = [CLChallenge]();
    var selectedChallenge: CLChallenge?;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let query = CLChallenge.query();
        query.orderByAscending("serial");
        self.tableView.hidden = true;
        self.viewSpinner.startAnimating();
        query.findObjectsInBackgroundWithBlock { (challengeArray, error) -> Void in
            if let e = error {
                CL.showError(e);
                self.tableView.hidden = false;
                self.viewSpinner.stopAnimating();
            } else {
                self.challengeArray = challengeArray as! [CLChallenge];
                self.tableView.reloadData();
                self.tableView.hidden = false;
                self.viewSpinner.stopAnimating();
            }
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if (self.searchBar.text == ""){
            CL.promote("Please enter search content");
            return;
        }
        
        let captionQuery = CLVideo.query();
        captionQuery.whereKey("caption", containsString: self.searchBar.text);
        captionQuery.whereKey("status", equalTo: CLVideo.STATUS.LISTING);
        captionQuery.cachePolicy = .NetworkElseCache;
        captionQuery.includeKey("challenge");
        captionQuery.includeKey("owner");
        captionQuery.includeKey("thumbNailImage");
        captionQuery.includeKey("file");
        captionQuery.orderByDescending("createdAt");
        
        let usernameInnerQuery = CLUser.query();
        usernameInnerQuery.whereKey("profileNameLowerCase", matchesRegex: self.searchBar.text?.lowercaseString);

        let usernameQuery = CLVideo.query();
        usernameQuery.whereKey("owner", matchesQuery: usernameInnerQuery);
        usernameQuery.whereKey("status", equalTo: CLVideo.STATUS.LISTING);
        usernameQuery.cachePolicy = .NetworkElseCache;
        usernameQuery.includeKey("challenge");
        usernameQuery.includeKey("owner");
        usernameQuery.includeKey("thumbNailImage");
        usernameQuery.includeKey("file");
        usernameQuery.orderByDescending("createdAt");

        let query = AVQuery.orQueryWithSubqueries([captionQuery, usernameQuery]);
        query.cachePolicy = .NetworkElseCache;
        query.includeKey("challenge");
        query.includeKey("owner");
        query.includeKey("thumbNailImage");
        query.includeKey("file");
        query.orderByDescending("createdAt");
        self.performSegueWithIdentifier("segueToVideoByCategory", sender: usernameQuery);
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
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
            cell.cellSpinner.startAnimating();
            cell.backgroundImageView.sd_setImageWithURL(NSURL(string: urlString)) { (image, error, cacheType, url) in
                //do nothing yet
                cell.cellSpinner.stopAnimating();
            }
        } else {
            cell.backgroundImageView.image = UIImage();
        }
        
        
        return cell;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        
        self.selectedChallenge = self.challengeArray[indexPath.row];
        let query = CLVideo.query();
        query.whereKey("challenge", equalTo: self.selectedChallenge);
        query.whereKey("status", equalTo: CLVideo.STATUS.LISTING);
        query.cachePolicy = .NetworkElseCache;
        query.includeKey("challenge");
        query.includeKey("owner");
        query.includeKey("thumbNailImage");
        query.includeKey("file");
        query.orderByDescending("createdAt");
        self.performSegueWithIdentifier("segueToVideoByCategory", sender: query);
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "segueToVideoByCategory") {
            let vc = segue.destinationViewController as! VideoByCategoryViewController;
            vc.videoQuery = sender as! AVQuery;
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.view.endEditing(true);
    }
}
