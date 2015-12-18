//
//  ViewController.swift
//  PicQurate
//
//  Created by SongXujie on 17/04/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LandingViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!

    override func viewDidLoad () {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.fbLoginButton.delegate = self;
        self.fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"];
    }
    
    override func viewWillAppear(animated: Bool) {
        if (CL.currentUser != nil && CL.currentUser.email != nil) {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            });
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonClicked(sender: UIButton) {
        self.performSegueWithIdentifier("loginSegue", sender: nil);
    }
    
    @IBAction func signupButtonClicked(sender: UIButton) {
        self.performSegueWithIdentifier("signupSegue", sender: nil);
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        FBSDKGraphRequest(graphPath: "me", parameters: nil).startWithCompletionHandler { (connection, user, error) -> Void in
            if let e = error {
                CL.showError(e);
            } else {
                let email = user["email"] as! String;
                let id = user["id"] as! String;
                let name = user["name"] as! String;
                var gender: NSNumber = false;
                if (user["gender"] as! String == "male") {
                    gender = true;
                } else {
                    gender = false;
                }
                
                //Due to presence of EnableAutomaticUser *\& Anonymous User,
                //1. Login with Faecbok Id
                //2. If error, check if 3 Wrong password or 4 user does not exist
                //3. Help user reset password
                //4. Help user 'sign up', by providing attributes to anonymous user and save.
                CLUser.logInWithUsernameInBackground(email, password: id, block: { (u, error) -> Void in
                    if let e = error {
                        if (e.code == 210) {
                            //User exists with wrong password
                            let alertController = UIAlertController(title: "Oops...", message: "This email had already linked to another PicQurate account. Would you like to reset the password?", preferredStyle: .Alert)
                            let okAction = UIAlertAction(title: "OK!", style: UIAlertActionStyle.Default) {
                                UIAlertAction in
                                //Reset Password
                                AVUser.requestPasswordResetForEmailInBackground(email, block: { (success, error) -> Void in
                                    if let e = error {
                                        CL.showError(e);
                                    } else {
                                        CL.promote("An email is on its way to your inbox! Please check the instructions inside.");
                                    }
                                });
                            }
                            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
                                UIAlertAction in
                                //Do nothing
                            }
                            alertController.addAction(okAction);
                            alertController.addAction(cancelAction);
                            self.presentViewController(alertController, animated: true, completion: nil);
                        } else if (e.code == 211) {
                            //User does not exist, save data to anonymous user
                            CL.currentUser.username = email;
                            CL.currentUser.email = email;
                            CL.currentUser.password = id;
                            CL.currentUser.profileName = name;
                            CL.currentUser.gender = gender;
                            CL.currentUser.signUpInBackgroundWithBlock({ (success, e) -> Void in
                                let urlString: String = "https://graph.facebook.com/" + id + "/picture?type=normal";
                                let data = NSData(contentsOfURL: NSURL(string: urlString)!);
                                let profileImage = UIImage(data: data!);
                                CL.currentUser.setProfileUIImage(profileImage!);
                                CL.currentUser.saveInBackground();
                                NSLog("Facebook sign up successful");
                                if let method = CL.delegate?.onUserRefreshed {
                                    method();
                                }
                                self.dismissViewControllerAnimated(true, completion: nil);
                            })
                        }
                    } else {
                        let user = u as! CLUser;
                        CL.currentUser = user;
                        NSLog("Facebook log in successful");
                        if let method = CL.delegate?.onUserRefreshed {
                            method();
                        }
                        self.dismissViewControllerAnimated(true, completion: nil);
                    }
                    
                    let fbLoginManager = FBSDKLoginManager();
                    fbLoginManager.logOut();
                });
                
            }
        }
    }
    
    @IBAction func skipButtonClicked(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        });
    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        AVUser.logOut();
        NSLog("Facebook user logged out");
    }

    @IBAction func termsButtonClicked(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string:"http://picqurate.com/EULA")!);
    }
}

