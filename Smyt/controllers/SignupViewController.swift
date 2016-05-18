//
//  SignUpViewController.swift
//  PicQurate
//
//  Created by SongXujie on 23/04/2015.
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation
import Toucan

protocol signupViewProtocol {
    func userLoggedin ();
}

class SignupViewController: UIViewController, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var delegate: signupViewProtocol!
    
    override func viewDidLoad() {
        
    }
    
    @IBAction func signupButtonClicked(sender: UIButton) {
        //Check if it's already signing up
        if (activityIndicator.isAnimating()) {
            return
        }
        //Check if sign up criteria is good enough
        let email : String = self.emailTextField.text!;
        if (!StringIsValidEmail(email)) {
            return
        }
        
        let passWord = self.passwordTextField.text!;
        if (passWord.characters.count < 8) {
            CL.promote("Please choose a longer password, minimum 8 character");
            return
        }
        
        let username = self.usernameTextField.text!;
        if (username.characters.count > 40) {
            CL.promote("Please choose a shorter profile name, maximum 40 character");
            return
        }
        
        //If it's logging in/Signing up, and criteria is good
        activityIndicator.startAnimating();
        
        //Saving profile image
        var user = CLUser();
        user.email = email
        user.username = email;
        user.password = passWord;
        user.profileName = username;
        user.profileNameLowerCase = username.lowercaseString;
//        CL.currentUser.username = email;
//        CL.currentUser.email = email;
//        CL.currentUser.password = passWord;
//        CL.currentUser.setObject(username, forKey: "profileName");
        user.signUpInBackgroundWithBlock { (success, error) -> Void in
            if let e = error {
                CL.showError(e);
            } else {
                CL.currentUser = CLUser.currentUser();
                if let image = self.profileImageButton.imageForState(.Normal) {
                    CL.currentUser.setProfileUIImage(image);
                }
                NSLog("Email user sign up successful");
                if let method = CL.delegate?.onUserRefreshed {
                    method();
                }
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    
                })
                self.delegate.userLoggedin();
            }
            self.activityIndicator.stopAnimating();
        }
//        CL.currentUser.saveInBackgroundWithBlock { (success, error) -> Void in
//            if let e = error {
//                CL.showError(e);
//            } else {
//                CL.currentUser = CLUser.currentUser();
//                if let image = self.profileImageButton.imageForState(.Normal) {
//                    CL.currentUser.setProfileUIImage(image);
//                }
//                NSLog("Email user sign up successful");
//                if let method = CL.delegate?.onUserRefreshed {
//                    method();
//                }
//                self.dismissViewControllerAnimated(true, completion: nil);
//            }
//            self.activityIndicator.stopAnimating();
//        }
    }
    
    @IBAction func cancelButtonClicked(sender: UIBarButtonItem!) {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        }
        return true
    }
    
    func StringIsValidEmail(email : String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluateWithObject(email)
        if result {
            return result
        } else {
            let alert = UIAlertView()
            alert.message = "Please enter a valid email!"
            alert.addButtonWithTitle("OK!")
            alert.show()
            return result
        }
    }
    
    @IBAction func profileImageViewClicked(sender: UIButton) {
        //Check if sign up criteria is good enough
        let alert = UIActionSheet();
        alert.title = "Pick your profile image from: "
        alert.delegate = self
        alert.addButtonWithTitle("Camera")
        alert.addButtonWithTitle("Photo Albums")
        alert.addButtonWithTitle("Cancel")
        alert.showInView(self.view.superview!);
    }
    
    func actionSheet(actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        if (buttonIndex == 0) {
            let picker = UIImagePickerController();
            picker.delegate = self;
            picker.allowsEditing = true;
            picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceType.Camera)!;
            picker.sourceType = UIImagePickerControllerSourceType.Camera;
            self.presentViewController(picker, animated: true, completion: nil);
        } else if (buttonIndex == 1) {
            let picker = UIImagePickerController();
            picker.delegate = self;
            picker.allowsEditing = true;
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary;
            self.presentViewController(picker, animated: true, completion: nil);
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        let clippedImage = Toucan.init(image: image).resize(CGSize(width: 120, height: 120),fitMode: Toucan.Resize.FitMode.Clip).image;
        let croppedImage = Toucan.init(image: clippedImage).resize(CGSize(width: 120, height: 120),fitMode: Toucan.Resize.FitMode.Crop).image;
        
        self.profileImageButton.setImage(croppedImage, forState: .Normal);
        picker.dismissViewControllerAnimated(true, completion: nil);
    }

    

}