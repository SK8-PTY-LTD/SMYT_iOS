//
//  HomeVideoTableViewCell.swift
//  Challenger
//
//  Created by SongXujie on 19/12/2015.
//  Copyright © 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation
import AVFoundation
import FBSDKCoreKit
import FBSDKShareKit
import MessageUI

protocol HomeVideoTableViewCellProtocol {
    func presentViewController(VC: UIViewController);
//    func verifyButtonClicked(video: CLVideo);
    func commentButtonClicked(video: CLVideo);
    func goToProfile(user: CLUser);
    func shareButtonClicked(video: CLVideo);
    func moreButtonClicked(video: CLVideo);
}

class HomeVideoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userProfileImage: UIImageView!
    @IBOutlet weak var userProfileName: UILabel!
    
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! //For video
    @IBOutlet weak var videoThumbnailView: AVImageView!
    @IBOutlet weak var imageActivityIndicator: UIActivityIndicatorView! //For image
    @IBOutlet weak var captionTextViewHeightConstraint: NSLayoutConstraint!
    
    var video: CLVideo!
    var shoulldInitiallyPlay = false;
    var delegate: HomeVideoTableViewCellProtocol?
    
    var videoPlayer: AVPlayer!
    var avLayer: AVPlayerLayer!
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)!
    }
    
    @IBAction func infoButtonClicked(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC = storyboard.instantiateViewControllerWithIdentifier("ChallengeDetailViewController") as! ChallengeDetailViewController;
        VC.challenge = video.challenge;
        self.delegate?.presentViewController(VC);
    }
    
    
    @IBAction func likeButtonClicked(sender: AnyObject) {
    
    }
    
    @IBAction func verifyButtonClicked(sender: UIButton) {
        if (self.verifyButton.imageForState(.Normal) == UIImage(named: "icon_like_0")) {
            if (CL.currentUser != nil && CL.currentUser.email != nil) {
                CL.currentUser.verifyVideo(self.video, verify: true);
                self.video.saveInBackground();
                self.verifyButton.setImage(UIImage(named: "icon_like_1"), forState: .Normal);
                
                //Send push
                let pushQuery = AVInstallation.query();
                pushQuery.whereKey("userId", equalTo: self.video.owner?.objectId);
                
                if let name = CL.currentUser["profileName"] as? String {
                    let data = ["type" : "1",
                                "alert" : name + " has smyt your video"];
                    CL.sendPush(pushQuery, data: data);
                } else {
                    let data = ["type" : "1",
                                "alert" : "Someone has smyt your video"];
                    CL.sendPush(pushQuery, data: data);
                }
            } else {
                CL.promote("Please login.");
            }
        } else {
            //Uncomment the following code if a challenge canbe 'unverified'
            if (CL.currentUser != nil && CL.currentUser.email != nil) {
                CL.currentUser.verifyVideo(self.video, verify: false);
                self.video.saveInBackground();
            }
            //self.video.numberOfVerify = self.video.numberOfVerify - 1;
            self.verifyButton.setImage(UIImage(named: "icon_like_0"), forState: .Normal);
        }
        self.likeButton.setTitle(" \(self.video.numberOfVerify) likes", forState: .Normal);
    }
    
    @IBAction func commentButtonClicked(sender: UIButton) {
        self.delegate?.commentButtonClicked(self.video);
    }
    
    @IBAction func shareButtonClicked(sender: UIButton) {
        self.delegate?.shareButtonClicked(self.video);
    }
    
    @IBAction func moreButtonClicked(sender: AnyObject) {
        self.delegate?.moreButtonClicked(self.video);
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        self.performSelector("customInitialize");
    }
    
    public func customInitialize() {
        
        //Play item
        if let _ = self.avLayer {
            //Cell already initialized
        } else {
            //Initialize cell
            CL.stampTime();
            let urlString = self.video.file?.url!;
            var url = NSURL(string: urlString!)!;
            let asset = AVURLAsset(URL: url);
            var videoItem = AVPlayerItem(asset: asset);
            //Initialize player
            //videoItem.
            self.videoPlayer = AVPlayer(playerItem: videoItem);
            self.videoPlayer.actionAtItemEnd = .None;
            CL.logWithTimeStamp("Cell Intialized");
            //Insert layer
            self.avLayer = AVPlayerLayer(player: self.videoPlayer);
            let width = UIScreen.mainScreen().bounds.width;
            self.avLayer.frame = CGRectMake(0, 0, width, width);
            self.videoThumbnailView.layer.addSublayer(self.avLayer);
            self.videoThumbnailView.clipsToBounds = true;
            //Add tap gesture
            let tap0 = UITapGestureRecognizer(target: self, action: Selector("handleVideoTap"));
            tap0.delegate = self;
            self.videoThumbnailView.addGestureRecognizer(tap0);
            
            let tap1 = UITapGestureRecognizer(target: self, action: Selector("handleUserTap"));
            tap1.delegate = self;
            self.userProfileImage.addGestureRecognizer(tap1);
            self.userProfileName.addGestureRecognizer(tap1);
        }
        
        //Autoplay the first item
        if shoulldInitiallyPlay {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoLoop", name:AVPlayerItemDidPlayToEndTimeNotification, object: self.videoPlayer!.currentItem);
            self.avLayer.hidden = false;
            self.videoPlayer.play();
            NSLog("showing video hiding thumbnail for initial play");
        }
        
        self.userProfileName.text = video.owner?.profileName;
        self.captionTextView.text = video.caption;
        //self.captionTextView.sizeToFit();
        //self.challengeLabel.text = video.challenge?.name;
        
        //Setting time
        //self.videoUploadTimeLabel.text = self.video.createdAt.formattedAsTimeAgo();
        
        //Check for verify state
        if (CL.currentUser != nil) {
            CL.currentUser.hasVerifiedVideoWithBlock(self.video) { (verified, error) -> () in
                if (verified) {
                    self.verifyButton.setImage(UIImage(named: "icon_like_1"), forState: .Normal);
                } else {
                    self.verifyButton.setImage(UIImage(named: "icon_like_0"), forState: .Normal);
                }
            }
        } else {
            //∂
        }
        
        if let owner = video.owner {
            if let img = owner.profileImage {
                self.imageActivityIndicator.startAnimating();
                self.userProfileImage.sd_setImageWithURL(NSURL(string: img.url), placeholderImage: UIImage(named: "default_profile")) { (image, error, cacheType, url) -> Void in
                    if let e = error {
                        NSLog("set profile image error");
                        CL.showError(e);
                    } else {
                        NSLog("profile image set successful");
                    }
                    self.imageActivityIndicator.stopAnimating();
                }
            }
        }
        
        
        //Set the video data
        self.likeButton.setTitle(" \(self.video.numberOfVerify) likes", forState: .Normal);
        self.commentButton.setTitle(" \(self.video.numberOfComment) comment", forState: .Normal);
        self.shareButton.setTitle(" \(self.video.numberOfView) View", forState: .Normal);
        
        //Increment number of views, since it's been viewed
        self.video.incrementKey("numberOfView");
        self.video.saveEventually();
    }
    
    func videoLoop() {
        self.videoPlayer?.currentItem?.seekToTime(kCMTimeZero);
        self.avLayer.hidden = false;
        self.videoPlayer.play();
    }
    
    func handleVideoTap() {
        if (self.videoPlayer.rate == 0.0) {
            self.avLayer.hidden = false;
            self.videoPlayer.play();
        } else {
            self.videoPlayer.pause();
        }
    }
    
    func handleUserTap() {
        self.delegate?.goToProfile(self.video.owner!);
    }
}