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

class VideoCaptureViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    @IBOutlet weak var timerLabel: UILabel!

    var challenge: CLChallenge!;
    var timer: NSTimer!;
    var timeMilli: Int = 0;
    var timeSec: Int = 0;
    var timeMin: Int = 0;
    var captureVideoPreviewLayer : AVCaptureVideoPreviewLayer!
    var session : AVCaptureSession!
    var movieFileOutput : AVCaptureMovieFileOutput!
    var backgroundRecordingID : UIBackgroundTaskIdentifier!
    
    override func viewDidLoad() {
        //        videoTimeControl.setThumbImage(UIImage(named: "thumb"), forState: UIControlState.Normal)
        startStreamLiveCanmera();
    }
    
    func startStreamLiveCanmera() {
        //----- SHOW LIVE CAMERA PREVIEW -----
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPreset1280x720
        
        captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        captureVideoPreviewLayer.frame.size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)
        captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.insertSublayer(captureVideoPreviewLayer, atIndex: 0)
        
        //Adding video input
        var videoDevice : AVCaptureDevice =  AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do {
            try videoDevice.lockForConfiguration();
        } catch {
            NSLog("error: device.lockForConfiguration()");
        }
        videoDevice.activeVideoMinFrameDuration = CMTimeMake(10,210)
        videoDevice.activeVideoMaxFrameDuration = CMTimeMake(10,210)
        videoDevice.unlockForConfiguration()
        
        //Adding audio input
        var audioDevice : AVCaptureDevice =  AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
        
        do {
            var input1 = try AVCaptureDeviceInput(device: videoDevice);
            var input2 = try AVCaptureDeviceInput(device: audioDevice);
            session.addInput(input1)
            session.addInput(input2)
        } catch {
            NSLog("ERROR: trying to open camera, and add input");
        }
        
        var movieFileOutput : AVCaptureMovieFileOutput = AVCaptureMovieFileOutput()
        if session.canAddOutput(movieFileOutput) {
            session.addOutput(movieFileOutput)
            var connection : AVCaptureConnection = movieFileOutput.connectionWithMediaType(AVMediaTypeVideo)
            if connection.supportsVideoStabilization {
                connection.preferredVideoStabilizationMode = .Auto
            }
            self.movieFileOutput = movieFileOutput
        }
        
        //Format the timer 00:00
        var timeNow = String(format: "%02d:%02d", self.timeMin, self.timeSec);
        //Display on your label
        self.timerLabel.text = timeNow;
        
        session.startRunning()
    }
    @IBAction func closeButtonClicked(sender: UIButton) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    func updateTimer() {
        self.timeMilli++
        if (self.timeMilli == 100) {
            self.timeMilli = 0;
            self.timeSec++
        }
        if (self.timeSec == 60) {
            self.timeSec = 0;
            self.timeMin++;
        }
        //Format the timer 00:00
        var timeNow = String(format: "%02d:%02d:%02d", self.timeMin, self.timeSec, self.timeMilli);
        //Display on your label
        self.timerLabel.text = timeNow;
    }
    
    @IBAction func flashButtonClicked(sender: UIButton) {
        // TODO: http://stackoverflow.com/questions/3190034/turn-on-torch-flash-on-iphone
    }
    
    @IBAction func flipButtonClicked(sender: UIButton) {
        // TODO: http://stackoverflow.com/questions/20864372/switch-cameras-with-avcapturesession
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
            
            //Add timer
            self.timer = NSTimer(timeInterval: 0.01, target: self, selector: "updateTimer", userInfo: nil, repeats: true);
            NSRunLoop.currentRunLoop().addTimer(self.timer, forMode: NSDefaultRunLoopMode);
            
            self.movieFileOutput.startRecordingToOutputFileURL(NSURL(fileURLWithPath: outputFilePath), recordingDelegate: self)
            
            //Reset timer
            self.timeMilli = 0;
            self.timeMin = 0;
            self.timeSec = 0;
            
        } else {
            self.movieFileOutput.stopRecording();
            self.timer.invalidate();
            //Stop timer
            self.timeMilli = 0;
            self.timeMin = 0;
            self.timeSec = 0;
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
        
        self.performSegueWithIdentifier("editVideoSegue", sender: outputFileURL);
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "editVideoSegue") {
            let outputURL = sender as! NSURL;
            let VC = segue.destinationViewController as! VideoEditViewController;
            VC.challenge = self.challenge;
            VC.outputURL = outputURL;
        }
    }
    
}

