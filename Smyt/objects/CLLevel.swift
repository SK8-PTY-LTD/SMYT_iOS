//================================================================================
//  CLLevel is a subclass of AVObject
//  Class name: Level
//  Author: Xujie Song
//  Copyright (c) 2015 SK8 PTY LTD. All rights reserved.
//================================================================================

import Foundation

public class CLLevel : AVObject, AVSubclassing {
    
    // ================================================================================
    // Constructors
    // ================================================================================
    
    public class func parseClassName() -> String {
        return "Level"
    }
    
    private override init() {
        super.init();
    }
    
    public init(user: CLUser, video: CLVideo, levelNumber: Int) {
        super.init();
        self.levelNumber = levelNumber;
        //self.challenge = challenge;
        self.user = user;
        self.video = video;
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
    
    @NSManaged dynamic var levelNumber: Int
    //@NSManaged dynamic var challenge: CLChallenge!
    @NSManaged dynamic var user: CLUser!
    @NSManaged dynamic var video: CLVideo!
    
    // ================================================================================
    // Export class
    // ================================================================================
    
}
