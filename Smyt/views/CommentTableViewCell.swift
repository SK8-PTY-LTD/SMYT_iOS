//
//  FriendTableViewCell.swift
//  Challenger
//
//  Created by SongXujie on 23/12/2015.
//  Copyright © 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

//protocol CommentTableViewCellProtocol {
//    func newCommentSent();
//}

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userProfileImage: AVImageView!
    @IBOutlet weak var userProfileName: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    
    var comment: CLComment!;
    
    //var delegate: CommentTableViewCellProtocol?
    
    required init(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)!
    }
    
    func loadComment() {
        if let url = self.comment.sender?.profileImage?.url {
            self.userProfileImage.sd_setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: "default_profile"));
        } else {
            self.userProfileImage.image = UIImage(named: "default_profile");
        }
        
//        self.userProfileImage.file = self.comment.sender?.profileImage;
//        self.userProfileImage.loadInBackground();
        self.userProfileName.text = self.comment.sender?.profileName;
        self.timeStampLabel.text = self.comment.createdAt.formattedAsTimeAgo();
        self.commentTextView.text = self.comment.text;
        //self.delegate!.newCommentSent();
    }
    
}