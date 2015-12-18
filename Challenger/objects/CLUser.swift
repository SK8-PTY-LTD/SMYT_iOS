//================================================================================
//  CLUser is a subclass of AVUser
//  Class name: _User
//  Author: Xujie Song
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//================================================================================

import Foundation

public class CLUser : AVUser {
    
    // ================================================================================
    // Constructors
    // ================================================================================
    
    public override class func parseClassName() -> String {
        return "_User"
    }
    
    override init() {
        super.init();
    }
    
    override init(className: String) {
        super.init(className: CLUser.parseClassName());
    }
    
    init(userId: String) {
        super.init();
        self.objectId = userId;
    }
    
    init(email: String, password: String, profileName: String) {
        super.init();
        self.username = email;
        self.email = email;
        self.password = password;
        self.balance = 0;
        self.profileName = profileName;
    }
    
    // ================================================================================
    // Class Properties
    // ================================================================================
    
    // ================================================================================
    // Shelf Methods
    // ================================================================================
    
    func isUser(user: CLUser) -> Bool {
        return self.objectId == user.objectId;
    }
    
    func isNotUser(user: CLUser) -> Bool {
        return !self.isUser(user);
    }
    
//    func hasLikedVideoWithBlock(video: CLVideo, callback: (liked :Bool, error: NSError?) -> ()) {
//        let query = self.relationforKey("videoLiked").query();
//        let videoId = video.objectId;
//        query.whereKey("objectId", equalTo:videoId);
//        query.countObjectsInBackgroundWithBlock { (count, error) -> Void in
//            if let e = error {
//                callback(liked: false, error: e);
//            } else {
//                let liked = (count == 1);
//                callback(liked: liked, error: nil);
//            }
//        }
//    }
//    
//    func hasVerifiedEmail() -> Bool {
//        return self.emailVerified as Bool;
//    }
//    
//    func uploadVideoWithBlock(image: UIImage, caption: String, block: (success: Bool, error: NSError?) -> ()) {
//        //Save file
//        let file = AVFile(name: "video.jpg", data: UIImageJPEGRepresentation(image, 1.0)) as! AVFile;
//        file.saveInBackgroundWithBlock({ (success, error) -> Void in
//            if let e = error {
//                block(success: false, error: e);
//            } else {
//                //Set lastVideo
//                
//                //Save CLVideo
//                let video = CLVideo(file: file);
//                video.caption = caption;
//                video.user = self;
//                NSLog("User gender is \(self.gender)");
//                video.gender = self.gender as Bool;
//                video.location = CL.currentUser.location;
//                video.locationString = CL.currentUser.locationString;
//                video.saveInBackgroundWithBlock({ (success, error) -> Void in
//                    if let e = error{
//                        block(success: false, error: e);
//                    } else {
//                        if let e = error{
//                            block(success: false, error: e);
//                        } else {
//                            block(success: true, error: nil);
//                        }
//                    }
//                })
//            }
//        })
//    }
//    
//    func likeVideo(video: CLVideo, like: Bool) {
//        // Add product to like query
//        let relation = self.relationforKey("videoLiked");
//        if (like) {
//            relation.addObject(video);
//        } else {
//            relation.removeObject(video);
//        }
//        self.saveInBackground();
//        
//        // Send a notification to the owner;
//        if (like) {
//            let message = self.getProfileName()! + " just liked your video";
//            video.fetchIfNeededInBackgroundWithBlock { (video, error) -> Void in
//                if let p = video as? CLVideo {
//                    
//                    let query = AVInstallation.query();
//                    query.whereKey("userId", equalTo: p.user?.objectId);
//                    
//                    CL.sendPushWithCallBack(query, message: message, callback: { (success, error) -> Void in
//                        if let _ = error {
//                            NSLog("Error sending push");
//                        } else {
//                            let push = CLPush(message: message, user: p.user!, video: p);
//                            push.saveInBackground();
//                        }
//                    });
//                    
//                } else {
//                    NSLog("Like Push not sent.");
//                }
//            }
//        }
//    }
//
//    func likeVideoWithBlock(video: CLVideo, like: Bool, block: (liked: Bool, error: NSError?) -> ()) {
//        // Add product to like query
//        let relation = self.relationforKey("videoLiked");
//        if (like) {
//            relation.addObject(video);
//        } else {
//            relation.removeObject(video);
//        }
//        self.saveInBackgroundWithBlock { (succeed, error) -> Void in
//            block(liked: like, error: error);
//        }
//        
//        // Send a notification to the owner;
//        if (like) {
//            let message = " just liked your video";
//            video.fetchIfNeededInBackgroundWithBlock { (video, error) -> Void in
//                if let p = video as? CLVideo {
//                    
//                    let query = AVInstallation.query();
//                    query.whereKey("userId", equalTo: p.user?.objectId);
//                    
//                    CL.sendPushWithCallBack(query, message: message, callback: { (success, error) -> Void in
//                        if let _ = error {
//                            NSLog("Error sending push");
//                        } else {
//                            let push = CLPush(message: message, user: p.user!, video: p);
//                            push.saveInBackground();
//                        }
//                    });
//                    
//                } else {
//                    NSLog("Like Push not sent.");
//                }
//            }
//        }
//    }
    
//    func getAddressWithCallBack(callback: (address :SHAddress?, error: NSError?) -> ()) {
//        if let address = self.getAddress() {
//            address.fetchInBackgroundWithBlock({ (address, error) -> Void in
//                callback(address: address as? SHAddress, error: error);
//            })
//        } else {
//            var error = NSError(domain: "http://www.shelf.is", code: 400, userInfo: [description: "Address is nil"])
//            callback(address: nil, error: error);
//        }
//    }
    
    
//    func getMembershipWithCallback(shop: SHShop, callback: (membership :SHMembership, error: NSError?) ->()) {
//        // Retrieve Membership
//        var query = SHMembership.query();
//        query.whereKey("user", equalTo: self);
//        query.whereKey("shop", equalTo: shop);
//        query.getFirstObjectInBackgroundWithBlock { (membership, error) -> Void in
//            callback(membership: membership as SHMembership, error: nil);
//        }
//    }
//    
//    func getProductLiked() -> AVRelation {
//        var likeRelation = self.relationforKey("productLiked");
//        likeRelation.targetClass = "Product";
//        return likeRelation;
//    }
//    
//    func getRatingWithCallback(callback: (rating: Int, error: NSError?) -> ()) {
//        // The object was retrieved successfully.
//        var query = SHPurchaseEntry.query();
//        query.whereKey("seller", equalTo: self);
//        query.findObjectsInBackgroundWithBlock { (list, error) -> Void in
//            if let e = error {
//                callback(rating: 5, error: e);
//            } else {
//                if (list.count != 0) {
//                    var rating = 0;
//                    for (var i = 0; i < list.count; i++) {
//                        var entry = list[i] as SHPurchaseEntry;
//                        rating += entry.getRating()!;
//                    }
//                    var result: Double = Double(rating) / Double(list.count)
//                    rating = Int(result);
//                    callback(rating: rating, error: nil);
//                } else {
//                    callback(rating: 5, error: nil);
//                }
//            }
//        }
//    }
//    
//    func getShopLiked() -> AVRelation {
//        var likeRelation = self.relationforKey("shopLiked");
//        likeRelation.targetClass = "Shop";
//        return likeRelation;
//    }
//    
//    func updateCard(token: STPToken) {
//        var params = ["tokenId": token.tokenId];
//        AVCloud.callFunctionInBackground("updateCard", withParameters: params, block: nil);
//    }
    
    // ================================================================================
    // Property setters and getters
    // ================================================================================
    
//    @NSManaged var addressId: String?
//    @NSManaged var backgroundImage: AVFile?
    @NSManaged var bio: String?
    @NSManaged var balance: Int
    @NSManaged var emailVerified: NSNumber
    @NSManaged var gender: NSNumber
    @NSManaged var installationId: String?
    @NSManaged var location: AVGeoPoint?
    @NSManaged var locationString: String?
//    @NSManaged var mobileNumber: String?
    @NSManaged var profileImage: AVFile?
    @NSManaged var profileName: String?
    @NSManaged var realName: String?
    @NSManaged var url: String?
    
//    var address: SHAddress? {
//        get {
//            if let id = self.addressId {
//                var address = SHAddress(addressId: id);
//                return address;
//            } else {
//                return nil;
//            }
//        }
//        set {
//            self.addressId = newValue?.objectId;
//        }
//    };
//    
//    func getAddress() -> SHAddress? {
//        if let addressId: AnyObject = self.objectForKey("addressId") {
//            var address = SHAddress(addressId: addressId as String);
//            return address;
//        } else {
//            return nil;
//        }
//    }
//    
//    func setAddress(address: SHAddress) {
//        self.setObject(address.objectId, forKey: "addressId");
//    }
//    
//    func getBackgroundImage() -> AVFile? {
//        return self.objectForKey("backgroundImage") as? AVFile;
//    }
//    
//    func setBackgroundImage(backgroundImage: UIImage) {
//        var imageFile: AVFile = AVFile.fileWithName("background.jpg", data: UIImageJPEGRepresentation(backgroundImage, 1.0)) as AVFile;
//        self.setObject(imageFile, forKey:"backgroundImage");
//        self.saveInBackground();
//    }
//    
//    func getBio() -> String? {
//        return self.objectForKey("bio") as? String;
//    }
//    
//    func setBio(bio: String) {
//        self.setObject(bio, forKey: "bio");
//    }
    
    func getInstallation() -> AVInstallation {
        if let installationId: String = self.objectForKey("installationId") as? String {
            let installation = AVInstallation(withoutDataWithObjectId: installationId);
            return installation;
        } else {
            let installation = AVInstallation.currentInstallation();
            self.setInstallation(installation);
            return installation;
        }
    }
    
    func setInstallation(installation: AVInstallation) {
        if let installationId = installation.objectId {
            self.setObject(installationId, forKey: "installationId");
        } else {
            NSLog("Installation is nil");
        }
    }
    
    func getMobileNumber() -> String? {
        return self.objectForKey("mobileNumber") as? String;
    }
    
    func setMobileNumber(number: String) {
        self.setObject(number, forKey: "mobileNumber");
        self.setObject(true, forKey: "mobilePhoneVerified");
        self.saveInBackground();
    }
    
    func getProfileImage() -> AVFile? {
        return self.objectForKey("profileImage") as? AVFile;
    }

    func setProfileUIImage(profileImage: UIImage) {
        let imageFile = AVFile(name: "profile.jpg", data: UIImageJPEGRepresentation(profileImage, 1.0)) as! AVFile;
        imageFile.saveInBackgroundWithBlock { (success, error) -> Void in
            if let e = error {
                NSLog("Profile image failed to save, error: " + e.localizedDescription);
            } else {
                self.profileImage = imageFile;
                self.saveInBackground();
            }
        }
    }

    func getProfileName() -> String? {
        return self.objectForKey("profileName") as? String;
    }

    private func setProfileName(profileName: String) {
        self.setObject(profileName, forKey: "profileName");
    }
    
    // ================================================================================
    // Export class
    // ================================================================================
    
}
