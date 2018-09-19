//
//  SwitchViewCell.swift
//  RxLearnDemo
//
//  Created by song on 2018/9/19.
//  Copyright © 2018年 song. All rights reserved.
//

import UIKit

class SwitchViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var swichBtn: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
