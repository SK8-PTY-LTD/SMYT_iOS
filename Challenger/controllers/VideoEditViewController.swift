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

class VideoEditViewController: UIViewController, ICGVideoTrimmerDelegate {
    
    var challenge: CLChallenge!;
    
    @IBOutlet weak var thumbnailImageView: AVImageView!
    @IBOutlet weak var trimmerView: ICGVideoTrimmerView!
    @IBOutlet weak var successButton: UIButton!
    @IBOutlet weak var failButton: UIButton!
    
    var startTime: Float64 = 0;
    var endTime: Float64 = 0;
    var movieFileOutput : AVCaptureMovieFileOutput!
    var backgroundRecordingID : UIBackgroundTaskIdentifier!
    var outputURL: NSURL!
    var trimViewLoaded: Bool = false;
    
    override func viewDidLoad() {
        
        super.viewDidLoad();
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //Resize trimview
        if self.trimmerView.bounds.size.width <= self.view.bounds.size.width && !self.trimViewLoaded {
            
            //Setting up trimmerView
            trimmerView.themeColor = UIColor.whiteColor()
            trimmerView.asset = AVAsset(URL: self.outputURL) as AVAsset;
            trimmerView.showsRulerView = false;
            trimmerView.trackerColor = UIColor.cyanColor();
            trimmerView.delegate = self;
            trimmerView.minLength = 10.0;
            trimmerView.maxLength = 10.0
            trimmerView.resetSubviews();
            self.trimViewLoaded = true;
            
            NSLog("Size is \(trimmerView.frame)");
            
            
        }
    }
    
    func trimmerView(trimmerView: ICGVideoTrimmerView!, didChangeLeftPosition startTime: CGFloat, rightPosition endTime: CGFloat) {
        self.startTime = Float64(startTime);
        self.endTime = Float64(endTime);
        NSLog("Trimmer changed, startAt: \(startTime), endAt: \(endTime)")
        
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
        //Disable button
        self.successButton.enabled = false;
        self.cropAndTrimVideo(self.startTime, duration: self.endTime - self.startTime, isSuccessVideo: true);
        
        //Promote user to pick fail
        var alert = UIAlertController(title: "Uploading video", message: "Would you like to upload a funny fail too?", preferredStyle: .ActionSheet);
        var acceptAction = UIAlertAction(title: "Ok!", style: .Default) { (action) -> Void in
            self.failButton.enabled = true;
        }
        var cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
            self.view.window?.rootViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
                
            });
        }
        alert.addAction(acceptAction);
        alert.addAction(cancelAction);
        self.presentViewController(alert, animated: true) { () -> Void in
            
        }
        
    }
    
    @IBAction func failButtonClicked(sender: UIButton) {
        self.cropAndTrimVideo(self.startTime, duration: self.endTime - self.startTime, isSuccessVideo: false);
        CL.promote("Uploading video");
        self.view.window?.rootViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        });
    }
    @IBAction func closeButtonClicked(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    func cropAndTrimVideo(start: Float64, duration: Float64, isSuccessVideo: Bool) {
        
        //load our movie Asset
        var asset : AVAsset = AVAsset(URL: self.outputURL) as AVAsset
        
        //create an avassetrack with our asset
        var clipVideoTrack : AVAssetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0] as AVAssetTrack
        
        //create a video composition and preset some settings
        var videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTimeMake(10, 210);
        
        //here we are setting its render size to its height x height (Square)
        videoComposition.renderSize = CGSizeMake(clipVideoTrack.naturalSize.height, clipVideoTrack.naturalSize.height);
        
        //create a video instruction
        var instruction : AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(60, 30))
        
        var transformer : AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        
        var t1 : CGAffineTransform = CGAffineTransformMakeTranslation(clipVideoTrack.naturalSize.height, 0);
        
        //Make sure the square is portrait
        var t2 : CGAffineTransform = CGAffineTransformRotate(t1, CGFloat(M_PI_2))
        
        var finalTransform : CGAffineTransform = t2
        
        transformer.setTransform(finalTransform, atTime: kCMTimeZero)
        
        //add the transformer layer instructions, then add to video composition
        instruction.layerInstructions = [transformer]
        
        videoComposition.instructions = [instruction]
        
        //Path
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        var exportPath = documentsPath.stringByAppendingString("/CroppedVideo.mp4")
        NSLog(exportPath);
        
        var exportUrl = NSURL(fileURLWithPath: exportPath)
        
        //Trimming video
        var startAt = CMTimeMakeWithSeconds(start, 21);
//        var duration = CMTimeMakeWithSeconds(duration, 21);   //Floating time
        var duration = CMTimeMakeWithSeconds(10.0, 21);     //Always 10 seconds
        var range = CMTimeRangeMake(startAt, duration);
        
        //Export
        var exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality)!
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
            var data = NSData(contentsOfURL: exportUrl);
            var file = AVFile(name: "\(self.challenge.serial). \(self.challenge.name) \(CL.currentUser.profileName).mp4", data: data);
            
            file.saveInBackgroundWithBlock({ (success, error) -> Void in
                if let e = error {
                    CL.showError(e);
                } else {
                    var video = CLVideo(file: file);
                    video.challenge = self.challenge;
                    video.isSuccessVideo = isSuccessVideo;
                    video.saveInBackgroundWithBlock({ (success, error) -> Void in
                        if let e = error {
                            CL.showError(e);
                        } else {
                            
                        }
                    });
                }
            })
            
            //Write to library
            ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(exportUrl, completionBlock: { (assetURL, error) -> Void in
                if error != nil {
                    NSLog("%@", error)
                }
                //Remove temporary file
                do {
                    try NSFileManager.defaultManager().removeItemAtURL(exportUrl)
                } catch {
                    NSLog("error: Error removing video from device");
                }
            })
        }
    }
    
    
}

