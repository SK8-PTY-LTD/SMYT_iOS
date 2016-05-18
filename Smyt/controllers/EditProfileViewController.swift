//
//  EditProfileViewController.swift
//  Challenger
//
//  Created by Shawn on 4/7/16.
//  Copyright © 2016 SK8 PTY LTD. All rights reserved.
//

import UIKit
import Toucan
import FontAwesome_swift
import FBSDKLoginKit
import FBSDKCoreKit
import FBSDKShareKit

class EditProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, EditProfileImageProtocol {
    
    var profileImageButton: UIButton!;
    var profileNameTextField: UITextField!;
    var emailTextField: UITextField!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true);
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6;
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.row == 0){
            return 100;
        } else {
            return 50;
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch (indexPath.row){
        case 0: //profile image section
            let cellIdentifier = "editProfileImageTableViewCell";
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! EditProfileImageTableViewCell;
            cell.accessoryType = UITableViewCellAccessoryType.None;
            cell.delegate = self;
            self.profileImageButton =  cell.profileImageButton;
            //configure profile image here
            if let img = CL.currentUser.profileImage{
                NSLog("\(img.url)");
                cell.profileImageButton.sd_setBackgroundImageWithURL(NSURL.init(string: img.url), forState: .Normal, placeholderImage: UIImage(named: "default_profile"));
            } else {
                cell.profileImageButton.setImage(UIImage(named: "default_profile"), forState: .Normal);
            }
            return cell;
        case 1:
            let cellIdentifier = "editProfileInformationTableViewCell";
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! EditProfileInformationTableViewCell;
            cell.accessoryType = UITableViewCellAccessoryType.None;
            cell.userInteractionEnabled = false;
            //cell.descriptionImageView.image = UIImage.fontAwesomeIconWithName(.User, textColor: UIColor.blackColor(), size: CGSizeMake(30, 30));
            cell.descriptionImageView.image = UIImage(named: "profile_username_icon");
            cell.descriptionLabel.text = "User Name:";
            cell.dataTextField.text = CL.currentUser.username;
            return cell;
        case 2:
            let cellIdentifier = "editProfileInformationTableViewCell";
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! EditProfileInformationTableViewCell;
            cell.accessoryType = UITableViewCellAccessoryType.None;
            cell.selectionStyle = UITableViewCellSelectionStyle.None;
            //cell.descriptionImageView.image = UIImage.fontAwesomeIconWithName(.NewspaperO, textColor: UIColor.blackColor(), size: CGSizeMake(30, 30));
            cell.descriptionImageView.image = UIImage(named: "profile_fullname_icon");
            cell.descriptionLabel.text = "Profile Name:";
            cell.dataTextField.text = CL.currentUser.profileName;
            self.profileNameTextField = cell.dataTextField;
            return cell;
        case 3:
            let cellIdentifier = "editProfileInformationTableViewCell";
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! EditProfileInformationTableViewCell;
            cell.accessoryType = UITableViewCellAccessoryType.None;
            cell.selectionStyle = UITableViewCellSelectionStyle.None;
            //cell.descriptionImageView.image = UIImage.fontAwesomeIconWithName(.EnvelopeO, textColor: UIColor.blackColor(), size: CGSizeMake(30, 30));
            cell.descriptionImageView.image = UIImage(named: "profile_email_icon");
            cell.descriptionLabel.text = "Email:";
            cell.dataTextField.text = CL.currentUser.email;
            self.emailTextField = cell.dataTextField;
            return cell;
        case 4:
            let cellIdentifier = "editProfileInformationTableViewCell";
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! EditProfileInformationTableViewCell;
            cell.descriptionImageView.image = UIImage.fontAwesomeIconWithName(.Weixin, textColor: UIColor.lightGrayColor(), size: CGSizeMake(30, 30));
            cell.descriptionLabel.text = "Change BIO";
            cell.dataTextField.hidden = true;
            return cell;
        case 5:
            let cellIdentifier = "editProfileInformationTableViewCell";
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! EditProfileInformationTableViewCell;
            cell.descriptionImageView.image = UIImage.fontAwesomeIconWithName(.Key, textColor: UIColor.lightGrayColor(), size: CGSizeMake(30, 30));
            cell.descriptionLabel.text = "Change Password";
            cell.dataTextField.hidden = true;
            return cell;
        default:
            let cellIdentifier = "editProfileInformationTableViewCell";
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! EditProfileInformationTableViewCell;
            cell.accessoryType = UITableViewCellAccessoryType.None;
            cell.selectionStyle = UITableViewCellSelectionStyle.None;
            cell.userInteractionEnabled = false;
            cell.descriptionImageView.hidden = true;
            cell.descriptionLabel.hidden = true;
            cell.dataTextField.hidden = true;
            return cell;
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true);
        if (indexPath.row == 5){
            self.performSegueWithIdentifier("segueToChangePassword", sender: nil);
        }
        
        if (indexPath.row == 4){
            self.performSegueWithIdentifier("segueToChangeBIO", sender: nil);
        }
    }
    
    @IBAction func doneButtonClicked(sender: AnyObject) {
        //Saving profile image
        
        CL.currentUser.saveInBackgroundWithBlock { (success, error) -> Void in
            if let e = error {
                CL.showError(e);
            } else {
                CL.currentUser.setObject(self.emailTextField.text, forKey: "email");
                CL.currentUser.setObject(self.profileNameTextField.text, forKey: "profileName");
                CL.currentUser.setObject(self.profileNameTextField.text?.lowercaseString, forKey: "profileNameLowerCase");
                
                if let image = self.profileImageButton.backgroundImageForState(.Normal) {
                    CL.currentUser.setProfileUIImage(image);
                }
                CL.currentUser.saveInBackground();
                
                CL.promote("Profile has been updated.");
                self.navigationController?.popViewControllerAnimated(true);
                
            }
            
        }
    }
    
    @IBAction func cancelButtonClicked(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true);
    }

    @IBAction func logoutButtonClicked(sender: AnyObject) {
        //Remove userID from current installtion
        if let _ = CL.currentUser {
            let installation = AVInstallation.currentInstallation();
            installation.setObject("", forKey: "userId");
            installation.saveInBackgroundWithBlock({ (success, error) -> Void in
                if (success) {
                    CL.currentUser.setInstallation(installation);
                    CL.currentUser.saveInBackground();
                    CL.currentUser = nil;
                } else {
                    CL.showError(error);
                }
            });
        }
        CLUser.logOut();
        FBSDKLoginManager().logOut();
        CL.promote("You have logged out");
        self.tabBarController?.selectedIndex = 0;
        self.navigationController?.popViewControllerAnimated(true);
        
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
        
        self.profileImageButton.setBackgroundImage(croppedImage, forState: .Normal);
        picker.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func profileImageButtonClicked(sender: UIButton){
        
        let alert = UIActionSheet();
        alert.title = "Pick your profile image from: "
        alert.delegate = self
        alert.addButtonWithTitle("Camera")
        alert.addButtonWithTitle("Photo Albums")
        alert.addButtonWithTitle("Cancel")
        alert.showInView(self.view.superview!);
    }
    
    

}
