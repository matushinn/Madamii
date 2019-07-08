//
//  TimeLineTableViewCell.swift
//  Login
//
//  Created by 大江祥太郎 on 2019/07/07.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit

class TimeLineTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var likeCountLabel: UILabel!
    
    @IBOutlet weak var timeStampLabel: UILabel!

    @IBOutlet weak var userTextView: UITextView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
