//================================================================================
//  CLComment is a subclass of AVObject
//  Class name: Comment
//  Author: Xujie Song
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//================================================================================

import Foundation

public class CLComment : AVObject, AVSubclassing {
    
    // ================================================================================
    // Constructors
    // ================================================================================
    
    public class func parseClassName() -> String {
        return "Comment"
    }
    
    private override init() {
        super.init();
    }
    
    public init(commentId: String) {
        super.init();
        self.objectId = commentId;
    }
    
    public init(sender: CLUser, video: CLVideo, text: String) {
        super.init();
        self.sender = sender;
        self.video = video;
        self.text = text;
    }
    
    // ================================================================================
    // Class properties
    // ================================================================================
    
    // ================================================================================
    // Shelf Methods
    // ================================================================================
    
    public func send(error: NSErrorPointer) -> NSError? {
        var error: NSError?
        self.save(&error);
        return error;
    }
    
    public func sendInBackgroundWithBlock(block: (comment: CLComment, error: NSError?) -> ()) {
        self.saveInBackgroundWithBlock { (success, error) -> Void in
            if (success) {
                block(comment: self, error: nil);
            } else {
                block(comment: self, error: error);
            }
        }
    }
    
    // ================================================================================
    // Property setters and getters
    // ================================================================================
    
    @NSManaged public dynamic var video: CLVideo?
    @NSManaged public dynamic var sender: CLUser?
    @NSManaged public dynamic var text: String?
    
    // ================================================================================
    // Export class
    // ================================================================================
    
}
