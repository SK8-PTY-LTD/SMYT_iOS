//
//  ChangeBIOViewController.swift
//  Challenger
//
//  Created by Shawn on 4/8/16.
//  Copyright © 2016 SK8 PTY LTD. All rights reserved.
//

import UIKit

class ChangeBIOViewController: UIViewController {

    @IBOutlet weak var bioTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.automaticallyAdjustsScrollViewInsets = false;
        
        self.bioTextView.text = CL.currentUser.bio;
    }

    @IBAction func backButtonClicked(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true);
    }
    
    @IBAction func saveButtonClicked(sender: AnyObject) {
        
        if (bioTextView.text == "" || bioTextView.text == nil){
            CL.promote("Please enter new BIO...")
        } else {
            CL.currentUser.saveInBackgroundWithBlock({ (succeed, error) in
                if let e = error {
                    CL.showError(e);
                } else {
                    CL.currentUser.setObject(self.bioTextView.text, forKey: "bio");
                    CL.currentUser.saveInBackground();
                    CL.promote("BIO has been changed.");
                    self.navigationController?.popViewControllerAnimated(true);
                }
            })
        }
    }
    
}
