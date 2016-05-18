//
//  ViewController.swift
//  PicQurate
//
//  Created by SongXujie on 17/04/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import FBSDKShareKit

protocol landingViewProtocol {
    func selectHomeTab();
}

class LandingViewController: UIViewController, FBSDKLoginButtonDelegate, signupViewProtocol, loginViewProtocol  {
    
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var delegate: landingViewProtocol!
    
    var userLoginSuccess = false;

    override func viewDidLoad () {
        super.viewDidLoad();
        // Do any additional setup after loading the view, typically from a nib.
        self.fbLoginButton.delegate = self;
        self.fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"];    
    }
    
    override func viewWillAppear(animated: Bool) {
//        if (CL.currentUser != nil && CL.currentUser.email != nil) {
//            self.dismissViewControllerAnimated(true, completion: { () -> Void in
//                self.delegate.selectHomeTab();
//            });
//        }
    }
    
    @IBAction func loginButtonClicked(sender: UIButton) {
        self.performSegueWithIdentifier("loginSegue", sender: nil);
    }
    
    @IBAction func signupButtonClicked(sender: UIButton) {
        self.performSegueWithIdentifier("signupSegue", sender: nil);
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        self.activityIndicatorView.startAnimating();
        FBSDKGraphRequest(graphPath: "me", parameters: nil).startWithCompletionHandler { (connection, user, error) -> Void in
            if let e = error {
                CL.showError(e);
            } else {
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"name,email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                    
                    let email = result["email"] as! String;
                    let id = result["id"] as! String;
                    let name = result["name"] as! String;
                    NSLog("my id is: \(id)");
                                        
//                //Due to presence of EnableAutomaticUser & Anonymous User,
//                //1. Login with Faecbok Id
//                //2. If error, check if 3 Wrong password or 4 user does not exist
//                //3. Help user reset password
//                //4. Help user 'sign up', by providing attributes to anonymous user and save.
                    CLUser.logInWithUsernameInBackground(email, password: id, block: { (u, error) -> Void in
                        if let e = error {
                            if (e.code == 210) {
                                //User exists with wrong password
                                let alertController = UIAlertController(title: "Oops...", message: "This email had already linked to another Challenges account. Would you like to reset the password?", preferredStyle: .Alert)
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
                                var user = CLUser(email: email, password: id, profileName: name);
                                user.fbId = id;
                                user.signUpInBackgroundWithBlock({ (success, e) -> Void in
                                    if let e = error {
                                        CL.showError(e)
                                    } else {
                                        let urlString: String = "https://graph.facebook.com/\(id)/picture?type=small&return_ssl_resources=1";
                                        NSLog("Mon's url is : \(urlString)");
                                        
                                        let data = NSData(contentsOfURL: NSURL(string: urlString)!);
                                        let profileImage = UIImage(data: data!);
                                        CL.currentUser = user;
                                        CL.currentUser.setProfileUIImage(profileImage!);
                                        CL.currentUser.saveInBackground();
                                        NSLog("Facebook sign up successful");
                                        self.userLoginSuccess = true;
                                        if let method = CL.delegate?.onUserRefreshed {
                                            method();
                                        }
                                        
                                    }
                                })
                            }
                        } else {
                            let user = u as! CLUser;
                            CL.currentUser = user;
                            NSLog("Facebook log in successful");
                            self.userLoginSuccess = true;
                            if let method = CL.delegate?.onUserRefreshed {
                                method();
                            }
//                            self.dismissViewControllerAnimated(true, completion: { () -> Void in
//                                self.delegate.selectHomeTab();
//                            })
                        }
                        
                        self.activityIndicatorView.stopAnimating();
                        self.userLoggedin();
                        //FBSDKLoginManager().logOut();
                    });
                    
                });
                
            }
            
        }
    }
    
    @IBAction func skipButtonClicked(sender: UIButton) {
        self.delegate.selectHomeTab();
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        });
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "loginSegue"){
            if let vc = segue.destinationViewController as? LoginViewController{
                vc.delegate = self;
            }
        }
        
        if (segue.identifier == "signupSegue"){
            if let vc = segue.destinationViewController as? SignupViewController{
                vc.delegate = self;
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        AVUser.logOut();
        FBSDKLoginManager().logOut();
        NSLog("Facebook user logged out");
    }

    @IBAction func termsButtonClicked(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string:"http://www.challengesapp.com/EULA")!);
    }
    
    func userLoggedin() {
        if (CL.currentUser != nil && CL.currentUser.email != nil) {
            //success
            NSLog("login successful, going to home");
            self.delegate.selectHomeTab();
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                if let _ = CL.currentUser {
                    let installation = AVInstallation.currentInstallation();
                    installation.setObject(CL.currentUser.objectId, forKey: "userId");
                    installation.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if (success) {
                            CL.currentUser.setInstallation(installation);
                            CL.currentUser.saveInBackground();
                        } else {
                            CL.showError(error);
                        }
                    });
                }
            })
        } else {
            NSLog("login failed");
            //Fail
        }
    }
}

