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

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    var captureVideoPreviewLayer : AVCaptureVideoPreviewLayer!
    var session : AVCaptureSession!
    var movieFileOutput : AVCaptureMovieFileOutput!
    var backgroundRecordingID : UIBackgroundTaskIdentifier!
    
    
    override func viewDidLoad() {
        //        videoTimeControl.setThumbImage(UIImage(named: "thumb"), forState: UIControlState.Normal)
        startStreamLiveCanmera()
    }
    
    func startStreamLiveCanmera() {
        //----- SHOW LIVE CAMERA PREVIEW -----
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPreset1280x720
        
        captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        captureVideoPreviewLayer.frame.size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)
        captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.insertSublayer(captureVideoPreviewLayer, atIndex: 0)
        
        var device : AVCaptureDevice =  AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do {
            try device.lockForConfiguration();
        } catch {
            NSLog("error: device.lockForConfiguration()");
        }
        device.activeVideoMinFrameDuration = CMTimeMake(10,200)
        device.activeVideoMaxFrameDuration = CMTimeMake(10,200)
        device.unlockForConfiguration()
        
        do {
            var input = try AVCaptureDeviceInput(device: device);
            session.addInput(input)
        } catch {
            NSLog("ERROR: trying to open camera, and add input");
        }
        
        var movieFileOutput : AVCaptureMovieFileOutput = AVCaptureMovieFileOutput()
        if session.canAddOutput(movieFileOutput) {
            session.addOutput(movieFileOutput)
            var connection : AVCaptureConnection = movieFileOutput.connectionWithMediaType(AVMediaTypeVideo)
            if connection.supportsVideoStabilization {
                connection.enablesVideoStabilizationWhenAvailable = true
            }
            self.movieFileOutput = movieFileOutput
            
        }
        
        session.startRunning()
    }
    
    @IBAction func takeVideo(sender: UIButton) {
        if !movieFileOutput.recording {
            //Check multitasking
            if UIDevice.currentDevice().multitaskingSupported {
                self.backgroundRecordingID = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
                    
                })
            }
            
            // Start recording to a temporary file.
            var outputFilePath = NSTemporaryDirectory().stringByAppendingString("movie.mov")
            self.movieFileOutput.startRecordingToOutputFileURL(NSURL(fileURLWithPath: outputFilePath), recordingDelegate: self)
            
        } else {
            self.movieFileOutput.stopRecording()
        }
    }
    
    @IBAction func deleteVideo(sender: UIButton) {
        
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
        
        /*
        
        //Crop the video using GPUImage
        var movieFile = GPUImageMovie(URL: outputFileURL)
        let cropFilter = GPUImageCropFilter(cropRegion: CGRectMake(230, 0, 720, 720))
        movieFile.addTarget(cropFilter)
        
        //Export
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        
        var exportPath = documentsPath.stringByAppendingString("/CroppedVideo.mp4")
        
        var exportUrl = NSURL(fileURLWithPath: exportPath)
        
        var movieURL = NSURL(fileURLWithPath: exportPath)
        var movieWriter = GPUImageMovieWriter(movieURL: movieURL, size: CGSizeMake(480.0, 640.0))
        cropFilter.addTarget(movieWriter)
        
        movieWriter.shouldPassthroughAudio = false
        movieFile.audioEncodingTarget = movieWriter
        movieFile.enableSynchronizedEncodingUsingMovieWriter(movieWriter)
        
        movieWriter.startRecording()
        movieFile.startProcessing()
        
        cropFilter.removeTarget(movieWriter)
        movieWriter.finishRecording()
        */
        
        
        //load our movie Asset
        var asset : AVAsset = AVAsset(URL: outputFileURL) as AVAsset
        
        //create an avassetrack with our asset
        var clipVideoTrack : AVAssetTrack = asset.tracksWithMediaType(AVMediaTypeVideo)[0] as AVAssetTrack
        
        //create a video composition and preset some settings
        var videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTimeMake(1, 21);
        
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
        
        var exportUrl = NSURL(fileURLWithPath: exportPath)
        
        //Export
        var exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality)!
        exporter.videoComposition = videoComposition
        exporter.outputURL = exportUrl;
        exporter.outputFileType = AVFileTypeMPEG4
        exporter.shouldOptimizeForNetworkUse = true;
        
        exporter.exportAsynchronouslyWithCompletionHandler { () -> Void in
            NSLog("Start saving video")
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                NSLog("Finished saving video")
                self.exportDidFinish(exporter)
            })
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

