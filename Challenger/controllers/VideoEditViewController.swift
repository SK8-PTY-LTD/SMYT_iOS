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

class VideoEditViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, ICGVideoTrimmerDelegate {
    
    @IBOutlet weak var thumbnailImageView: AVImageView!
    @IBOutlet weak var trimmerView: ICGVideoTrimmerView!
    
    var startTime: CGFloat = 0;
    var endTime: CGFloat = 0;
    var movieFileOutput : AVCaptureMovieFileOutput!
    var backgroundRecordingID : UIBackgroundTaskIdentifier!
    var outputURL: NSURL!
    
    override func viewDidLoad() {
        
        //Setting up trimmerView
        trimmerView.themeColor = UIColor.whiteColor()
        trimmerView.asset = AVAsset(URL: self.outputURL) as AVAsset;
        trimmerView.showsRulerView = false;
        trimmerView.trackerColor = UIColor.cyanColor();
        trimmerView.delegate = self;
        trimmerView.minLength = 0.0;
        trimmerView.maxLength = 10.0
        trimmerView.resetSubviews();
        NSLog("Size is \(trimmerView.frame)");

    }
    
    func trimmerView(trimmerView: ICGVideoTrimmerView!, didChangeLeftPosition startTime: CGFloat, rightPosition endTime: CGFloat) {
        self.startTime = startTime;
        self.endTime = endTime;
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
        self.cropAndTrimVideo(kCMTimeZero, duration: CMTimeMake(10, 21))
        CL.promote("Uploading video");
    }
    
    @IBAction func failButtonClicked(sender: UIButton) {
        CL.promote("Failing video");
    }
    @IBAction func closeButtonClicked(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    func cropAndTrimVideo(start: CMTime, duration: CMTime) {
        
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
        var range = CMTimeRangeMake(kCMTimeZero, CMTimeMake(10, 21));
        
        //Export
        var exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality)!
        exporter.timeRange = range;
        exporter.videoComposition = videoComposition
        exporter.outputURL = exportUrl;
        exporter.outputFileType = AVFileTypeMPEG4
        exporter.shouldOptimizeForNetworkUse = true;
        
        exporter.exportAsynchronouslyWithCompletionHandler { () -> Void in
            NSLog("Start saving video")
            switch (exporter.status) {
            case AVAssetExportSessionStatus.Completed:
                //                [self writeVideoToPhotoLibrary:[NSURL fileURLWithPath:outputURL]];
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
            
            //Write to library
            ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(exportUrl, completionBlock: { (assetURL, error) -> Void in
                if error != nil {
                    NSLog("%@", error)
                }
                do {
                    //Remove temporary file
                    try NSFileManager.defaultManager().removeItemAtURL(exportUrl)
                } catch {
                    NSLog("error: Error writing video to device");
                }
            })
        }
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        if error != nil {
            NSLog("Error")
        }
        
        // Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
        var backgroundRecordingID = self.backgroundRecordingID
        self.backgroundRecordingID = UIBackgroundTaskInvalid
        if self.backgroundRecordingID != UIBackgroundTaskInvalid {
            UIApplication.sharedApplication().endBackgroundTask(self.backgroundRecordingID)
        }
        
        //load our movie Asset
        var asset : AVAsset = AVAsset(URL: outputFileURL) as AVAsset
        
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
        var startAt = CMTimeMakeWithSeconds(0.0, 21);
        var duration = CMTimeMakeWithSeconds(10.0, 21);
        var range = CMTimeRangeMake(startAt, duration);
        
        //Export
        var exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality)!
        exporter.timeRange = range;
        exporter.videoComposition = videoComposition
        exporter.outputURL = exportUrl;
        exporter.outputFileType = AVFileTypeMPEG4
        exporter.shouldOptimizeForNetworkUse = true;
        
        exporter.exportAsynchronouslyWithCompletionHandler { () -> Void in
            NSLog("Start saving video")
            switch (exporter.status) {
            case AVAssetExportSessionStatus.Completed:
                //                [self writeVideoToPhotoLibrary:[NSURL fileURLWithPath:outputURL]];
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
            self.exportDidFinish(exporter);
        }
    }
    
    func exportDidFinish(session : AVAssetExportSession) {
        //Play the New Cropped video
        var outputURL = session.outputURL;
        
        //Write to library
        ALAssetsLibrary().writeVideoAtPathToSavedPhotosAlbum(outputURL, completionBlock: { (assetURL, error) -> Void in
            if error != nil {
                NSLog("%@", error)
            }
            do {
                try NSFileManager.defaultManager().removeItemAtURL(outputURL!)
            } catch {
                NSLog("error: Error writing video to device");
            }
        })
        
        //        var asset = AVURLAsset(URL: outputFileURL, options: nil)
        //        var gen = AVAssetImageGenerator(asset: asset)
        //        gen.appliesPreferredTrackTransform = true
        //
        //        for index in 1...60 {
        //            println("current time is \(index / 20)")
        //            var time = CMTimeMakeWithSeconds(Float64(index), 20)
        //            var error : NSError?
        //            var actualTime : CMTime = CMTimeMake(Int64(index), 20)
        //            var image = gen.copyCGImageAtTime(time, actualTime: &actualTime, error: &error)
        //            var thumb = UIImage(CGImage: image)
        //            testImageView.image = thumb
        //
        //        }
    }
    
}

