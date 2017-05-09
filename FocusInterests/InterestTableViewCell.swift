//
//  InterestTableViewCell.swift
//  FocusInterests
//
//  Created by Amber Spadafora on 5/8/17.
//  Copyright © 2017 singlefocusinc. All rights reserved.
//

import UIKit

class InterestTableViewCell: UITableViewCell {

    
    @IBOutlet weak var selectedInterestLabel: UILabel!
    @IBOutlet weak var checkMarkImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
