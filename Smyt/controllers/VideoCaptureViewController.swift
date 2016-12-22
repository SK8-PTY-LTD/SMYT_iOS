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
    @IBOutlet weak var cameraFlipButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!

    var challenge: CLChallenge!;
    var timer: NSTimer!;
    var timeMilli: Int = 0;
    var timeSec: Int = 0;
    var timeMin: Int = 0;
    var captureVideoPreviewLayer : AVCaptureVideoPreviewLayer!
    var session : AVCaptureSession!
    var movieFileOutput : AVCaptureMovieFileOutput!
    var backgroundRecordingID : UIBackgroundTaskIdentifier!
    var isUsingCameraBack: Bool = true;
    var audioDeviceInUse: AVCaptureDeviceInput? = nil;
    var videoDeviceInUse: AVCaptureDevice? = nil;
    var torchIsOn: Bool = false;
    var isRecording: Bool = false;
    
    override func viewDidLoad() {
        //        videoTimeControl.setThumbImage(UIImage(named: "thumb"), forState: UIControlState.Normal)
        UIApplication.sharedApplication().statusBarStyle = .LightContent;
        startStreamLiveCanmera();
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.enabled = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true);
        navigationController?.interactivePopGestureRecognizer?.enabled = true
        UIApplication.sharedApplication().statusBarStyle = .Default;
    }
    
    func startStreamLiveCanmera() {
        //----- SHOW LIVE CAMERA PREVIEW -----
        session = AVCaptureSession();
        session.sessionPreset = AVCaptureSessionPresetHigh;
        
        captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: session);
        
        captureVideoPreviewLayer.frame.size = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)
        captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.view.layer.insertSublayer(captureVideoPreviewLayer, atIndex: 0)
        
        //Adding video input
        var videoDevice : AVCaptureDevice =  AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo);
        self.videoDeviceInUse = videoDevice;
        
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
            self.audioDeviceInUse = input2;
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
        var timeNow = String(format: "%02d:%02d:%02d", self.timeMin, self.timeSec,  self.timeMilli);
        //Display on your label
        self.timerLabel.text = timeNow;
        
        session.startRunning()
        
    }
    @IBAction func closeButtonClicked(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true);
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
        
        let captureDeviceClass = NSClassFromString("AVCaptureDevice");
        
        if (captureDeviceClass != nil) {
            if (self.videoDeviceInUse!.hasFlash && self.videoDeviceInUse!.hasTorch){
                do {
                    try self.videoDeviceInUse?.lockForConfiguration();
                    if (self.videoDeviceInUse?.torchMode == AVCaptureTorchMode.On){
                        self.videoDeviceInUse?.torchMode = AVCaptureTorchMode.Off;
                        flashButton.setImage(UIImage(named: "flash-off.png"), forState: .Normal);
                    } else {
                        try self.videoDeviceInUse!.setTorchModeOnWithLevel(AVCaptureMaxAvailableTorchLevel);
                        flashButton.setImage(UIImage(named: "flash-on.png"), forState: .Normal);
                    }
                    self.videoDeviceInUse!.unlockForConfiguration();
                } catch {
                    NSLog("Torch configuration error!!...");
                }
            }
        }
    }
    
    @IBAction func flipButtonClicked(sender: UIButton) {
        
        if ((session) != nil) {
            //Start session configuration
            session.beginConfiguration();
            
            //Remove all inputs from current session
            for currentInput in session.inputs {
                session.removeInput(currentInput as! AVCaptureInput);
            }
            
            //Create new camera input
            var newCamera: AVCaptureDevice? = nil;
            
            if (isUsingCameraBack) {
                newCamera = self.cameraWithPosition(AVCaptureDevicePosition.Front);
                isUsingCameraBack = false;
            } else {
                newCamera = self.cameraWithPosition(AVCaptureDevicePosition.Back);
                isUsingCameraBack = true;
            }
            self.videoDeviceInUse = newCamera;
            
            //Add input to session
            do {
                let newVideoInput = try AVCaptureDeviceInput.init(device: newCamera);
                session.addInput(newVideoInput);
                session.addInput(self.audioDeviceInUse);
                session.commitConfiguration();
            } catch {
                NSLog("Error creating capture device input");
            }
        }
        
    }
        
    //Function gets desired device position and returns device at that position
    func cameraWithPosition (position: AVCaptureDevicePosition) -> AVCaptureDevice?{
        //Find all video devices
        let deviceArray = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo);
        
        //Find device at position
        for device in deviceArray {
            if (device.position == position){
                return device as? AVCaptureDevice;
            }
        }
        
        return nil;
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
            cameraFlipButton.hidden = true;
            
            //Reset timer
            self.timeMilli = 0;
            self.timeMin = 0;
            self.timeSec = 0;
            
        } else {
            self.movieFileOutput.stopRecording();
            self.timer.invalidate();
            cameraFlipButton.hidden = false;
            
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

