//
//  ChallengeDetailViewController.swift
//  Challenger
//
//  Created by SongXujie on 19/12/2015.
//  Copyright © 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

class ChallengeDetailViewController: UIViewController {
    
    var challenge: CLChallenge!;
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var instructionTextView: UITextView!
    @IBOutlet weak var requirementTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.navigationBar.items![0].title = "CHALLENGE \(self.challenge.serial)";
        self.titleLabel.text = self.challenge.name;
//        self.instructionTextView.text = self.challenge.instruction;
        self.requirementTextView.text = self.challenge.requirement;
    }
    
    @IBAction func closeButtonClicked(sender: UIButton) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    @IBAction func beginButtonClicked(sender: UIButton) {
        self.performSegueWithIdentifier("segueToUpload", sender: self.challenge);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "segueToUpload") {
            let VC = segue.destinationViewController as! VideoCaptureViewController;
            VC.challenge = self.challenge!;
        }
    }
}