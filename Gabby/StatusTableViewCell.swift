//
//  StatusTableViewCell.swift
//  Gabby
//
//  Created by Dan Brajkovic on 6/3/15.
//  Copyright (c) 2015 Pragmatic Labs, LLC. All rights reserved.
//

import UIKit

class StatusTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var timeSentLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let layer = self.avatarView.layer
        layer.cornerRadius = 6.0
        self.avatarView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
