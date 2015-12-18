//================================================================================
//  CLVideo is a subclass of AVObject
//  Class name: Video
//  Author: Xujie Song
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//================================================================================

import Foundation

public class CLVideo : AVObject, AVSubclassing {
    
    // ================================================================================
    // Constructors
    // ================================================================================
    
    public class func parseClassName() -> String {
        return "Video"
    }
    
    private override init() {
        super.init();
    }
    
    public init(videoId: String) {
        super.init();
        self.objectId = videoId;
    }
    
    public init(file: AVFile) {
        super.init();
        self.file = file;
        self.status = CLVideo.STATUS.LISTING;
        self.owner = CL.currentUser;
    }
    
    // ================================================================================
    // Class properties
    // ================================================================================
    
    struct STATUS {
        static let LISTING = 0
        static let REPORTED = 700
        static let DELISTED = 800
        static let DELETED = 900
    }
    
    
    // ================================================================================
    // Shelf Methods
    // ================================================================================
    
    public func getCommentsQuery() -> AVQuery {
        let query = CLComment.query();
        query.orderByAscending("createdAt");
        query.whereKey("video", equalTo:self);
        return query;
    }
    
    public func getLikedUserQuery() -> AVQuery {
        let userQuery = AVRelation.reverseQuery(CLUser.parseClassName(), relationKey: "videoLiked", childObject: self);
        return userQuery;
    }
    
    //================================================================================
    //Property setters and getters
    //================================================================================
    
    @NSManaged public dynamic var challenge: CLChallenge?
    @NSManaged public dynamic var file: AVFile?
    @NSManaged public dynamic var coverImage: AVFile?
    @NSManaged public dynamic var numberOfVerify: Int
    @NSManaged public dynamic var imageArray: [AVFile]!;
    @NSManaged public dynamic var owner: CLUser?;
    @NSManaged public dynamic var status: Int;
    @NSManaged public dynamic var summary: String?;
    @NSManaged public dynamic var numberOfVerifyRequired: Int

    //Do not remove coverImage codes, might be useful in the future
//    private var cachedCoverUIImage: UIImage!
//    public dynamic var coverUIImage: UIImage? {
//        get {
//            if let image = self.cachedCoverUIImage {
//                return image;
//            } else {
//                SHLog.i("Cover image is nil");
//                return nil;
//            }
//        }
//        set {
//            self.cachedCoverUIImage = newValue;
//            let file = AVFile.fileWithName("coverImage.jpg", data: UIImageJPEGRepresentation(newValue!, 1.0)) as! AVFile;
//            file.saveInBackgroundWithBlock { (success, error) -> Void in
//                if let e = error {
//                    SHLog.e(e);
//                } else {
//                    self.coverImage = file;
//                    self.saveInBackground();
//                }
//            }
//        }
//    }
    
    //================================================================================
    //Export class
    //================================================================================
    
}