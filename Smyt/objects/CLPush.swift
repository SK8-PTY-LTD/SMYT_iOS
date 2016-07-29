//================================================================================
//  CLPush is a subclass of AVObject
//  Class name: Photo
//  Author: Xujie Song
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//================================================================================

import Foundation

class CLPush : AVObject, AVSubclassing {
    
    // ================================================================================
    // Constructors
    // ================================================================================
    
    class func parseClassName() -> String? {
        return "Push"
    }
    
    override init() {
        super.init();
    }
    
    init(pushId: String) {
        super.init();
//        self.objectId = pushId;
    }
    
    init(message: String, user: CLUser, video: CLVideo?) {
        super.init();
        self.sender = CL.currentUser;
        self.user = user;
        self.message = message;
        if (video != nil){
            self.video = video!
        }
    }
    
    // ================================================================================
    // Class properties
    // ================================================================================
    
    // ================================================================================
    // Shelf Methods
    // ================================================================================
    
    
    
    // ================================================================================
    // Property setters and getters
    // ================================================================================
    
    @NSManaged var user: CLUser!
    @NSManaged var sender: CLUser!
    @NSManaged var message: String!
    @NSManaged var video: CLVideo?
    
    // ================================================================================
    // Export class
    // ================================================================================
    
}
