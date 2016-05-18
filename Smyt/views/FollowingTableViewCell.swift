//
//  FollowingTableViewCell.swift
//  Challenger
//
//  Created by Shaoxuan Shen on 16/1/12.
//  Copyright © 2016年 SK8 PTY LTD. All rights reserved.
//

import Foundation

protocol FollowingTableViewProtocol {
    func followButtonClicked(cell: FollowingTableViewCell);
}

class FollowingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var followerProfileImageView: AVImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var delegate: FollowingTableViewProtocol!
    var userToDisplay: CLUser!
    
    @IBAction func followButtonClicked(sender: AnyObject) {
        self.delegate.followButtonClicked(self);
    }
}