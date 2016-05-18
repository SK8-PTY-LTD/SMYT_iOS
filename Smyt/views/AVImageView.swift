//================================================================================
//  AVImageView.swift
//  Author: Xujie Song
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//================================================================================

import UIKit

public class AVImageView: UIImageView {
    
    @IBInspectable public var MINIMUM_WIDTH: CGFloat = 160;
    @IBInspectable public var MINIMUM_Height: CGFloat = 160;
    
    public dynamic var file: AVFile?;
    private var cachedFile: AVFile?;
    private var scale: CGFloat = UIScreen.mainScreen().scale;
    
    public func loadInBackground() {
        
        if (self.cachedFile?.objectId == self.file?.objectId && self.image != nil) {
            //Image already loaded, do nothing
            return;
        } else {
            self.cachedFile = self.file;
        }
        
        if let imageFile = self.file {
            var width = self.frame.width;
            if (width < MINIMUM_WIDTH) {
                width = MINIMUM_WIDTH;
            }
            var height = self.frame.height;
            if (height < MINIMUM_Height) {
                height = MINIMUM_Height;
            }
            if (!imageFile.isDataAvailable) {
                if let data = imageFile.getData() {
                    let image = UIImage(data: data);
                    self.image = image;
                } else {
                    NSLog("Failed to load becuase image file had not uploaded and its data is nil");
                }
            } else {
                imageFile.getThumbnail(false, width: Int32(width * self.scale), height: Int32(height * self.scale), withBlock: { (image, error) -> Void in
                    if let e = error {
                        NSLog("\(e)");
                    } else {
                        self.image = image;
                    }
                })
            }
        } else {
            let error = NSError(domain: "http://www.shelf.is", code: 400, userInfo: [NSLocalizedDescriptionKey: "Error loading image: file hadn't been set."]);
            NSLog("\(error)");
        }
    }
    
    public func loadInBackground(scaleToFit: Bool) {
        
        if (self.cachedFile?.objectId == self.file?.objectId && self.image != nil) {
            //Image already loaded, do nothing
            return;
        } else {
            self.cachedFile = self.file;
        }
        
        if let imageFile = self.file {
            var width = self.frame.width;
            if (width < MINIMUM_WIDTH) {
                width = MINIMUM_WIDTH;
            }
            var height = self.frame.height;
            if (height < MINIMUM_Height) {
                height = MINIMUM_Height;
            }
            if (!imageFile.isDataAvailable) {
                if let data = imageFile.getData() {
                    let image = UIImage(data: data);
                    self.image = image;
                } else {
                    NSLog("Failed to load becuase image file had not uploaded and its data is nil");
                }
            } else {
                imageFile.getThumbnail(scaleToFit, width: Int32(width * self.scale), height: Int32(height * self.scale), withBlock: { (image, error) -> Void in
                    if let e = error {
                        NSLog("\(e)");
                    } else {
                        self.image = image;
                    }
                })
            }
        } else {
            let error = NSError(domain: "http://www.shelf.is", code: 400, userInfo: [NSLocalizedDescriptionKey: "Error loading image: file hadn't been set."]);
            NSLog("\(error)");

        }
    }
    
    public func loadInBackgroundWithBlock(block: AVDataResultBlock!) {
        
        if (self.cachedFile?.objectId == self.file?.objectId && self.image != nil) {
            //Image already loaded, do nothing
            return;
        } else {
            self.cachedFile = self.file;
        }
        
        if let imageFile = self.file {
            var width = self.frame.width;
            if (width < MINIMUM_WIDTH) {
                width = MINIMUM_WIDTH;
            }
            var height = self.frame.height;
            if (height < MINIMUM_Height) {
                height = MINIMUM_Height;
            }
            if (!imageFile.isDataAvailable) {
                if let data = imageFile.getData() {
                    let image = UIImage(data: data);
                    self.image = image;
                } else {
                    NSLog("Failed to load becuase image file had not been uploaded and its data is nil");
                }
            } else {
                imageFile.getThumbnail(false, width: Int32(width * self.scale), height: Int32(height * self.scale), withBlock: { (downloadedImage, error) -> Void in
                    if let e = error {
                        block(nil, error);
                        NSLog("\(e)");
                    } else {
                        self.image = downloadedImage;
                        let data = UIImagePNGRepresentation(downloadedImage);
                        block(data, nil);
                    }
                })
            }
        } else {
            let error = NSError(domain: "http://www.shelf.is", code: 400, userInfo: [NSLocalizedDescriptionKey: "Error loading image: file hadn't been set."]);
            NSLog("\(error)");
        }
    }
    
    
}

