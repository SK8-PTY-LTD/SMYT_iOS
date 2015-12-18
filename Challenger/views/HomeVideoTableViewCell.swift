//
//  HomeVideoTableViewCell.swift
//  Challenger
//
//  Created by SongXujie on 19/12/2015.
//  Copyright © 2015 SK8 PTY LTD. All rights reserved.
//

import Foundation

class HomeVideoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userProfileImage: AVImageView!
    @IBOutlet weak var userProfileName: UILabel!
    @IBOutlet weak var videoUploadTimeLabel: UILabel!
    @IBOutlet weak var videoPlayView: UIView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func infoButtonClicked(sender: UIButton) {
        
    }
    
    @IBAction func reportButtonClicked(sender: UIButton) {
    }
    
    @IBAction func verifyButtonClicked(sender: UIButton) {
    }
    
    @IBAction func commentButtonClicked(sender: UIButton) {
    }
    
    @IBAction func shareButtonClicked(sender: UIButton) {
    }
    
}