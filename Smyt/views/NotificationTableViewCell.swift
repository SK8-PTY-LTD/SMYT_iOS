//
//  NotificationTableViewCell.swift
//  
//
//  Created by SongXujie on 15/03/2016.
//
//

import Foundation

protocol NotificationTableViewCellProtocol {
    func userSelected(user: CLUser);
    func videoSelected(video: CLVideo);
}

class NotificationTableViewCell: UITableViewCell {
    
    var delegate: NotificationTableViewCellProtocol!
    
    @IBOutlet weak var notificationTextView: UITextView!
    @IBOutlet weak var profileImageView: UIButton!
    
    @IBOutlet weak var cellContentView: UIView!
    
    
    var notification: CLPush!;
    
    @IBAction func profileImageClicked(button: UIButton) {
        NSLog("sender: \(self.notification.sender)");
        self.delegate.userSelected(self.notification.sender);
    }
    
    override func layoutSubviews() {
        let f = self.cellContentView.frame;
        let fr = UIEdgeInsetsInsetRect(f, UIEdgeInsetsMake(10, 10, 10, 10));
        contentView.frame = fr;
    }
}