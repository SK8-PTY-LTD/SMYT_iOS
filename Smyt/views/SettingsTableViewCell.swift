//
//  SettingsTableViewCell.swift
//  Challenger
//
//  Created by Shawn on 1/03/2016.
//  Copyright © 2016 SK8 PTY LTD. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    @IBOutlet weak var settingNameLabel: UILabel!
    @IBOutlet weak var FBStatusButton: UIButton!
    @IBOutlet weak var videoSwitch: UISwitch!

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func switchChanged(sender: UISwitch) {
        if (sender.on){
            CL.isNotAutoLoading = false;
        } else {
            CL.isNotAutoLoading = true;
        }
    }
}
