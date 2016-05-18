//
//  CategoryTableViewCell.swift
//  Smyt
//
//  Created by Shawn on 4/05/2016.
//  Copyright © 2016 SK8 PTY LTD. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var categoryTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func smytButtonClicked(sender: AnyObject) {
    
    }  

}
