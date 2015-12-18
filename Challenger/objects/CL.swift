//
//  CL.swift
//  DropShop
//
//  Created by SK8 Admin on 8/12/2014.
//  Copyright (c) 2014 Xujie Song. All rights reserved.
//

import Foundation

extension UIImage {
    public func resize(size:CGSize, completionHandler:(resizedImage:UIImage, data:NSData)->()) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), { () -> Void in
            let newSize:CGSize = size
            let rect = CGRectMake(0, 0, newSize.width, newSize.height)
            UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
            self.drawInRect(rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            let imageData = UIImageJPEGRepresentation(newImage, 0.5)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                completionHandler(resizedImage: newImage, data:imageData!)
            })
        })
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hex: String!) {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet() as NSCharacterSet).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = cString.substringFromIndex(cString.startIndex.advancedBy(1))
        }
        
        if (cString.characters.count != 6) {
            self.init(
                red: CGFloat(255.0) / 255.0,
                green: CGFloat(102.0) / 255.0,
                blue: CGFloat(0.0) / 255.0,
                alpha: CGFloat(1.0)
            )
        } else {
            var rgbValue:UInt32 = 0
            NSScanner(string: cString).scanHexInt(&rgbValue)
            
            self.init(
                red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0)
            )
        }
    }
    
    func toHexString() -> String {
        var red: CGFloat = 0.0;
        var green: CGFloat = 0.0;
        var blue: CGFloat = 0.0;
        var alpha: CGFloat = 0.0;
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha);
        
        let redString = String(Int(red), radix: 16);
        let greenString = String(Int(green), radix: 16);
        let blueString = String(Int(blue), radix: 16);
        let hex = "#" + redString + greenString + blueString;
        return hex;
    }
}

extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
}

@objc protocol CLProtocol: UITextFieldDelegate {
    optional func onUserRefreshed();
}

class CL: NSObject {
    
    // Workaround:
    struct Static {
        
        // This is just for the sake of Android, has to have it
        
        static let AV_APP_ID = "UjFi1SbKQAXpNaGqOjtGalDR";
        static let AV_APP_KEY = "G0OGS5h97g7IdvoID70izkFX";
        
        static let PRIMARY_COLOR: UIColor = UIColor(hex: "#BE0004");
        
        static var currentUser: CLUser?;
        
        static var delegate: CLProtocol?;
    }
    
    class var primaryColor: UIColor {
        get { return Static.PRIMARY_COLOR }
    }
    
    class var currentUser: CLUser! {
        get { return Static.currentUser }
        set { Static.currentUser = newValue }
    }
    
    class var delegate: CLProtocol? {
        get { return Static.delegate }
        set { Static.delegate = newValue }
    }
    
    class func initialize(launchOptions: [NSObject: AnyObject]!) {
        
        //When app starts, set up AV
        
        //Reggister Subclass
        CLUser.registerSubclass();
        CLChallenge.registerSubclass();
        CLVideo.registerSubclass();
        CLComment.registerSubclass();
        
        //Initialization connection with Server
        AVOSCloud.useAVCloudUS();
        AVOSCloud.setApplicationId("pEDLbnxPOEzJHCrBXH1R1W9I-gzGzoHsz", clientKey: "bbU7nwbR3DFPVzTA9WWSCEvP");
        AVAnalytics.trackAppOpenedWithLaunchOptions(launchOptions);
        
        CLUser.enableAutomaticUser();
        
        if let user = CLUser.currentUser() {
            CL.currentUser = user as CLUser;
            CL.currentUser.saveInBackground();
            NSLog("User exists \(user)");
        } else {
            AVAnonymousUtils .logInWithBlock({ (anonymousUser, error) -> Void in
                if let _ = error {
                    NSLog("Anonymouse User login error \(error)");
                } else {
                    NSLog("Anonymouse User logged in");
                    CL.currentUser = CLUser.currentUser();
                }
            })
        }
        
    }
    
    class func sendPush(query: AVQuery, message: String) -> NSError? {
        var error: NSError?
        let push = AVPush();
        push.setQuery(query);
        push.setMessage(message);
        do {
            try push.sendPush()
        } catch let error1 as NSError {
            error = error1
        }
        return error;
    }
    
    class func sendPushWithCallBack(query: AVQuery, message: String, callback: AVBooleanResultBlock) {
        let notification = AVPush();
        notification.setQuery(query);
        notification.setMessage(message);
        notification.sendPushInBackgroundWithBlock(callback);
    }
    
    class func showError(error: NSError) {
        NSLog("Error: " + error.localizedDescription);
        let errorString = error.localizedDescription;
        let alert = UIAlertView()
        alert.title = "Oops";
        alert.message = errorString
        alert.addButtonWithTitle("OK!")
        alert.show()
    }
    
    class func promote(message: String) {
        NSLog("Info: " + message);
        let alert = UIAlertView()
        alert.title = "PicQurate";
        alert.message = message
        alert.addButtonWithTitle("OK!")
        alert.show()
    }
    
}
