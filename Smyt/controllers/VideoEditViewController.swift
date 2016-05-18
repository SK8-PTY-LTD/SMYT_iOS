//
//  ViewController.swift
//  Challenger
//
//  Created by SongXujie on 1/12/2015.
//  Copyright © 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation
import AVFoundation
import AssetsLibrary
import ICGVideoTrimmer
import UIKit
import SwiftSpinner

class VideoEditViewController: UIViewController, ICGVideoTrimmerDelegate {
    
    var challenge: CLChallenge!;
    
    @IBOutlet weak var profileImageView: AVImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var thumbnailImageView: AVImageView!
    @IBOutlet weak var trimmerView: ICGVideoTrimmerView!
    
    var startTime: Float64 = 0;
    var endTime: Float64 = 0;
    var videoDuration: Int = 0;
    var movieFileOutput : AVCaptureMovieFileOutput!
    var backgroundRecordingID : UIBackgroundTaskIdentifier!
    var outputURL: NSURL!
    var trimViewLoaded: Bool = false;
    var thumbnailDataAfterTrim: NSData!
    
    override func viewDidLoad() {
        
        super.viewDidLoad();
        
        if let user = CL.currentUser {
            if let url = user.profileImage?.url{
                self.profileImageView.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: "default_profile"));
            }
            
//            self.profileImageView.file = user.profileImage;
//            self.profileImageView.loadInBackground();
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true);
        UIApplication.sharedApplication().statusBarStyle = .LightContent;
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true);
        UIApplication.sharedApplication().statusBarStyle = .Default;
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //Resize trimview
        if self.trimmerView.bounds.size.width <= self.view.bounds.size.width && !self.trimViewLoaded {
            
            //Setting up trimmerView
            self.trimmerView.themeColor = UIColor.whiteColor()
            self.trimmerView.leftThumbImage = UIImage(named: "thumb_image");
            self.trimmerView.rightThumbImage = UIImage(named: "thumb_image");
//            trimmerView.thumbWidth = 60.0;
            self.trimmerView.asset = AVAsset(URL: self.outputURL) as AVAsset;
            
            self.trimmerView.showsRulerView = false;
            self.trimmerView.trackerColor = CL.primaryColor;
            self.trimmerView.delegate = self;
            self.trimmerView.minLength = 6.0;
            self.trimmerView.maxLength = CGFloat(CMTimeGetSeconds(self.trimmerView.asset.duration));
//            self.trimmerView.maxLength = 60.0;
            self.trimmerView.resetSubviews();
            self.trimViewLoaded = true;
            
            NSLog("Size is \(trimmerView.frame)");
            
            
        }
    }
    
    func trimmerView(trimmerView: ICGVideoTrimmerView!, didChangeLeftPosition startTime: CGFloat, rightPosition endTime: CGFloat) {
        self.startTime = Float64(startTime);
        self.endTime = Float64(endTime);
        self.videoDuration = Int(round(self.endTime - self.startTime));
        NSLog("Trimmer changed, startAt: \(startTime), endAt: \(endTime)");
        
        //Dealing with thumbnail
        var asset = AVURLAsset(URL: self.outputURL, options: nil)
        var gen = AVAssetImageGenerator(asset: asset)
        gen.appliesPreferredTrackTransform = true
        
            var time = CMTimeMakeWithSeconds(Float64(startTime), 21)
            var error : NSError?
            var actualTime : CMTime = CMTimeMake(Int64(startTime), 21)
            do {
                var image = try gen.copyCGImageAtTime(time, actualTime: &actualTime)
                var thumb = UIImage(CGImage: image)
                self.thumbnailImageView.image = thumb
            } catch {
                NSLog("error capturing thumbnail");
            }
        
    }
    
    @IBAction func successButtonClicked(sender: UIButton) {
        
        if let caption = self.captionTextView.text {
            if (caption.characters.count > 140){
                CL.promote("Caption should be less than 140 characters.");
                return;
            }
            
//            if (caption == "") {
//                CL.promote("Please enter caption.");
//                return;
//            }
        }
        //Disable button
        //self.successButton.enabled = false;
        self.cropAndTrimVideo(self.startTime, duration: self.endTime - self.startTime, isSuccessVideo: true);
        
        //Promote user to pick fail
//        var alert = UIAlertController(title: "Uploading video", message: "Would you like to upload a funny fail too?", preferredStyle: .ActionSheet);
//        var acceptAction = UIAlertAction(title: "Ok!", style: .Default) { (action) -> Void in
//            self.failButton.enabled = true;
//        }
//        var cancelAction = UIAlertAction(title: "No, thanks!", style: .Cancel) { (action) -> Void in
//            self.view.window?.rootViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
//                
//            });
            
//            self.dismissViewControllerAnimated(true, completion: nil);
//        }
//        alert.addAction(acceptAction);
//        alert.addAction(cancelAction);
//        self.presentViewController(alert, animated: true) { () -> Void in
//            
//        }
        
    }
    
//    @IBAction func failButtonClicked(sender: UIButton) {
//        if let caption = self.captionTextView.text {
//            if (caption.characters.count > 140){
//                CL.promote("Caption should be less than 140 characters.");
//                return;
//            }
//            
//            if (caption == "") {
//                CL.promote("Please enter caption.");
//                return;
//            }
//        }
//        
//        self.cropAndTrimVideo(self.startTime, duration: self.endTime - self.startTime, isSuccessVideo: false);
//        CL.promote("Uploading video");
////        self.view.window?.rootViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
////            
////        });
//        self.dismissViewControllerAnimated(true, completion: nil);
//    }
    
    @IBAction func closeButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { 
            //Do nothing
        }
    }
    
    func cropAndTrimVideo(start: Float64, duration: Float64, isSuccessVideo: Bool) {
        SwiftSpinner.show("Processing video", animated: true);
        
        //load our movie Asset
        let asset : AVAsset = AVAsset(URL: self.outputURL) as AVAsset;
        
        //create an avassetrack with our asset
        let clipVideoTrack : AVAssetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0] as AVAssetTrack;
        
        //create a video composition and preset some settings
        let videoComposition = AVMutableVideoComposition();
        videoComposition.frameDuration = CMTimeMake(Int64(self.videoDuration),Int32(self.videoDuration * 21));
        
        //here we are setting its render size to its height x height (Square)
        videoComposition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.height);
        
        //create a video instruction
        let instruction : AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30))
        
        let transformer : AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        
        let t1 : CGAffineTransform = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, 0);
        
        //Make sure the square is portrait
        let t2 : CGAffineTransform = CGAffineTransformRotate(t1, CGFloat(M_PI_2))
        
        let finalTransform : CGAffineTransform = t2
        
        transformer.setTransform(finalTransform, atTime: kCMTimeZero)
        
        //add the transformer layer instructions, then add to video composition
        instruction.layerInstructions = [transformer]
        
        videoComposition.instructions = [instruction]
        
        //Path
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        let exportPath = documentsPath.stringByAppendingString("/CroppedVideo.mp4")
        NSLog(exportPath);
        
        let exportUrl = NSURL(fileURLWithPath: exportPath)
        
        //Remove temporary file
        do {
            try NSFileManager.defaultManager().removeItemAtURL(exportUrl);
        } catch {
            NSLog("error: Error removing video from device");
        }
        
        //Trimming video
        let startAt = CMTimeMakeWithSeconds(start, 21);
//        var duration = CMTimeMakeWithSeconds(duration, 21);   //Floating time
        let duration = CMTimeMakeWithSeconds(self.endTime - self.startTime, 21);     //Always 10 seconds
        let range = CMTimeRangeMake(startAt, duration);
        
        //Export
        let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality)!
        exporter.timeRange = range;
        exporter.videoComposition = videoComposition
        exporter.outputURL = exportUrl;
        exporter.outputFileType = AVFileTypeMPEG4
        exporter.shouldOptimizeForNetworkUse = true;
        
        exporter.exportAsynchronouslyWithCompletionHandler { () -> Void in
            switch (exporter.status) {
            case AVAssetExportSessionStatus.Completed:
                NSLog("Export Complete \(exporter.status) \(exporter.error)");
                break;
            case AVAssetExportSessionStatus.Failed:
                NSLog("Export Failed \(exporter.status) \(exporter.error)");
                break;
            case AVAssetExportSessionStatus.Cancelled:
                NSLog("Export Cancelled \(exporter.status) \(exporter.error)");
                break;
                
            default:
                break;
            }
            
            let data = NSData(contentsOfURL: exportUrl);
            NSLog("123");
            //NSLog("\(self.challenge.serial)");
            //NSLog("\(self.challenge.name)");
            NSLog("\(CL.currentUser.profileName).mp4");
            let file = AVFile(name: "\(CL.currentUser.profileName).mp4", data: data);
            
            NSLog("321");
            //Generate thumbnail image
            let croppedAsset = AVURLAsset(URL: exportUrl, options: nil);
            let imgGenerator = AVAssetImageGenerator(asset: croppedAsset);
            do {
                let cgImage = try imgGenerator.copyCGImageAtTime(CMTimeMake(0, 1), actualTime: nil);
                let thumbnailImage = UIImage(CGImage: cgImage);
                self.thumbnailDataAfterTrim = UIImageJPEGRepresentation(thumbnailImage, 0.65);
            } catch {
                NSLog("error capturing thumbnail after trim/crop!");
            }
            
//            SwiftSpinner.show("Uploading Video", animated: true);
            //Save video file
            file.saveInBackgroundWithBlock({ (success, error) -> Void in
                if let e = error {
                    //CL.showError(e);
//                    SwiftSpinner.show(e.localizedDescription + ", Please try again.").addTapHandler({ 
//                        SwiftSpinner.hide();
//                    })
                } else {
                    
                    //Save thumbnail image
                    let thumbNailImage = AVFile(name: "thumbNailImage.jpg", data: self.thumbnailDataAfterTrim);
                    
                    thumbNailImage.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if let e = error {
                            //CL.showError(e);
//                            SwiftSpinner.show(e.localizedDescription + ", Please try again.").addTapHandler({
//                                SwiftSpinner.hide();
//                            })
                        } else {
                            
                            //Save video object
                            let video = CLVideo(file: file);
                            video.challenge = self.challenge;
                            video.isSuccessVideo = isSuccessVideo;
                            video.thumbNailImage = thumbNailImage;
                            video.caption = self.captionTextView.text;
                            video.saveInBackgroundWithBlock({ (success, error) -> Void in
                                if let e = error {
//                                    SwiftSpinner.show(e.localizedDescription + ", Please try again.").addTapHandler({
//                                        SwiftSpinner.hide();
//                                    })
                                } else {
//                                    SwiftSpinner.show("Upload successful.").addTapHandler({
//                                        SwiftSpinner.hide();
//                                        self.dismissViewControllerAnimated(true, completion: nil);
//                                        }, subtitle: "Tap to continue.")
                                    //Save level
                                    let level = CLLevel(user: CL.currentUser, video: video, levelNumber: CL.currentUser.level+1);
                                    level.saveInBackground();
                                    CL.currentUser.incrementKey("level");
                                    CL.currentUser.saveInBackground();
                                }
                            });
                        }
                    });
                }
                
            });
            self.dismissViewControllerAnimated(true, completion: nil);
            /*
            //Write to library
            //Comment out the following code to prevent saving the video to photo album
            ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(exportUrl, completionBlock: { (assetURL, error) -> Void in
                if error != nil {
                    NSLog("%@", error)
                }
                //Remove temporary file
                do {
                    try NSFileManager.defaultManager().removeItemAtURL(exportUrl);
                } catch {
                    NSLog("error: Error removing video from device");
                }
            })
            */
        }
    }
    
    
}

