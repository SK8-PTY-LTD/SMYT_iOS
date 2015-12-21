//
//  HomeVideoTableViewCell.swift
//  Challenger
//
//  Created by SongXujie on 19/12/2015.
//  Copyright © 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation
import AVFoundation

protocol HomeVideoTableViewCellProtocol {
    func presentViewController(VC: UIViewController);
}

class HomeVideoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userProfileImage: AVImageView!
    @IBOutlet weak var userProfileName: UILabel!
    @IBOutlet weak var videoUploadTimeLabel: UILabel!
    @IBOutlet weak var challengeLabel: UILabel!
    @IBOutlet weak var videoPlayView: UIView!
    
    var video: CLVideo!
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
    
    @IBAction func reportButtonClicked(sender: UIButton) {
    }
    
    @IBAction func verifyButtonClicked(sender: UIButton) {
    }
    
    @IBAction func commentButtonClicked(sender: UIButton) {
    }
    
    @IBAction func shareButtonClicked(sender: UIButton) {
    }
    
    override func layoutSubviews() {
        super.layoutSubviews();
        self.performSelector("loadInBackground");
    }
    
    public func loadInBackground() {
        
        self.userProfileImage.file = video.owner?.profileImage;
        self.userProfileImage.loadInBackground();
        self.userProfileName.text = video.owner?.profileName;
        self.challengeLabel.text = video.challenge?.name;
        
        //Setting time
        //MARK: - Instance Methods
        func printDate(date:NSDate) -> String {
            let dateFormatter = NSDateFormatter()//3
            
            var theDateFormat = NSDateFormatterStyle.ShortStyle //5
            let theTimeFormat = NSDateFormatterStyle.ShortStyle//6
            
            dateFormatter.dateStyle = theDateFormat//8
            dateFormatter.timeStyle = theTimeFormat//9
            
            return dateFormatter.stringFromDate(date)//11
        }
        
        self.videoUploadTimeLabel.text = printDate(video.createdAt);
        
        var url = NSURL(string: (video.file?.url!)!);
        var videoItem = AVPlayerItem(URL: url!);
        self.videoPlayer = AVPlayer(playerItem: videoItem);
        self.videoPlayer.actionAtItemEnd = .None;
        
        //Notification center
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoLoop", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.videoPlayer!.currentItem)
        
        //Play item
        if let _ = self.avLayer {
            
        } else {
            self.avLayer = AVPlayerLayer(player: self.videoPlayer);
            let width = UIScreen.mainScreen().bounds.width;
            self.avLayer.frame = CGRectMake(0, 0, width, width);    //375 is for iPhone6
            self.videoPlayView.layer.addSublayer(self.avLayer);
        }
    }
    
    func videoLoop() {
        self.videoPlayer?.currentItem?.seekToTime(kCMTimeZero)
        self.videoPlayer?.play()
    }
}