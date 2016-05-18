//
//  ChangePasswordViewController.swift
//  Challenger
//
//  Created by Shawn on 4/8/16.
//  Copyright © 2016 SK8 PTY LTD. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var passwordTextField1: UITextField!
    @IBOutlet weak var passwordTextField2: UITextField!
    @IBOutlet weak var passwordTextField3: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func backButtonClicked(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true);
    }
    
    @IBAction func saveButtonClicked(sender: AnyObject) {
        //Implement save password
        if (self.passwordTextField2.text != self.passwordTextField3.text){
            CL.promote("Please make sure two passwords in form are the same.");
            return;
        }
        
        if (self.passwordTextField2.text?.characters.count <= 6){
            CL.promote("Password must be longer than 6 characters");
            return;
        }
        
        CL.currentUser.updatePassword(self.passwordTextField1.text, newPassword: self.passwordTextField2.text) { (reply, error) in
            if let e = error {
                CL.showError(e);
            } else {
                CL.promote("Password has been changed");
                self.navigationController?.popViewControllerAnimated(true);
            }
        }   
    }
    
}
