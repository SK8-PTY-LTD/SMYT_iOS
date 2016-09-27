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
    
    var videoPlayer: AVPlayer?
    var avLayer : AVPlayerLayer!
    
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
    
    func videoLoop() {
        self.videoPlayer?.currentItem?.seekToTime(kCMTimeZero);
        self.avLayer.hidden = false;
        self.videoPlayer!.play();
    }
    
//    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
//        if context == ItemStatusContext {
//            print(change)
//        }
//        super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
//        return
//    }
    let ItemStatusContext: UnsafeMutablePointer<Void> = nil
    func handleVideoTap() {
        print("tapped!")
        print(self.video)
        print(self.videoPlayer)
        if (self.videoPlayer!.rate == 0.0) {
            
//            videoPlayer.currentItem?.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.Initial, context: ItemStatusContext)
//            self.videoPlayer
            self.avLayer.hidden = false;
            self.videoPlayer!.play();
//            print(videoPlayer.error)
            print(videoPlayer!.currentItem?.status)
//            print(avLayer)
            print("play!")
//            print(avLayer.hidden)
//            print(video.file?.url)
            print(videoPlayer!.currentItem)
            
        } else {
            self.videoPlayer!.pause();
//            print(videoPlayer.error)
            print(videoPlayer!.currentItem?.status)
//            print(avLayer.hidden)
//            print(video.file?.url)
            print("pause!!")
            print(videoPlayer!.currentItem)
        }
    }

    func handleUserTap() {
        self.delegate?.goToProfile(self.video.owner!);
    }
}