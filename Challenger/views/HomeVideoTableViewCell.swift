//
//  HomeVideoTableViewCell.swift
//  Challenger
//
//  Created by SongXujie on 19/12/2015.
//  Copyright © 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation
import AVFoundation

class HomeVideoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userProfileImage: AVImageView!
    @IBOutlet weak var userProfileName: UILabel!
    @IBOutlet weak var videoUploadTimeLabel: UILabel!
    @IBOutlet weak var videoPlayView: UIView!
    
    var video: CLVideo!
    
    
    var videoPlayer: AVPlayer!
    var avLayer: AVPlayerLayer!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func infoButtonClicked(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let VC = storyboard.instantiateViewControllerWithIdentifier("ChallengeDetailViewController") as! ChallengeDetailViewController;
        VC.challenge = video.challenge;
        var tableView = self.superview as! UITableView;
        var rootVC = tableView.delegate as! UIViewController;
        rootVC.presentViewController(VC, animated: true, completion: nil);
    }
    
    @IBAction func reportButtonClicked(sender: UIButton) {
    }
    
    @IBAction func verifyButtonClicked(sender: UIButton) {
    }
    
    @IBAction func commentButtonClicked(sender: UIButton) {
    }
    
    @IBAction func shareButtonClicked(sender: UIButton) {
    }
    
    public func loadInBackground() {
        var url = NSURL(string: (video.file?.url!)!);
        var videoItem = AVPlayerItem(URL: url!);
        self.videoPlayer = AVPlayer(playerItem: videoItem);
        self.videoPlayer.actionAtItemEnd = .None;
        
        //Notification center
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoLoop", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.videoPlayer!.currentItem)
        
        //Play item
        self.avLayer = AVPlayerLayer(player: self.videoPlayer);
        self.avLayer.frame = videoPlayView.frame;
        self.videoPlayView.layer.addSublayer(self.avLayer);
        self.videoPlayer.play();
        self.contentView.addSubview(self.videoPlayView)
    }
    
    func videoLoop() {
        self.videoPlayer?.pause()
        self.videoPlayer?.currentItem?.seekToTime(kCMTimeZero)
        self.videoPlayer?.play()
    }
}