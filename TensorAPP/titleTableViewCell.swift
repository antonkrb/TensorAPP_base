//
//  titleTableViewCell.swift
//  TensorAPP
//
//  Created by ААА on 27.10.16.
//  Copyright © 2016 Anton Korobeynikov. All rights reserved.
//

import UIKit

class titleTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
