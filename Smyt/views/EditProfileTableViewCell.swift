//
//  EditProfileTableViewCell.swift
//  Challenger
//
//  Created by Shawn on 4/7/16.
//  Copyright © 2016 SK8 PTY LTD. All rights reserved.
//

import UIKit

protocol EditProfileImageProtocol {
    func profileImageButtonClicked(sender: UIButton);
}

class EditProfileImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageButton: UIButton!;
    
    var delegate: EditProfileImageProtocol!;
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func profileImageButtonClicked(sender: UIButton) {
        self.delegate.profileImageButtonClicked(sender);
    }
    
}


class EditProfileInformationTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dataTextField: UITextField!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}

