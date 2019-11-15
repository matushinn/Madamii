//
//  TimeLineTableViewCell.swift
//  Login
//
//  Created by 大江祥太郎 on 2019/07/07.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit

//共通化
protocol TimeLineTableViewCellDelegate {
    func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton)
    func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton)
    func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton)
}

class TimeLineTableViewCell: UITableViewCell {

    var delegate: TimeLineTableViewCellDelegate?
    
    @IBOutlet weak var topicImageView: UIImageView!
    
    @IBOutlet weak var commentRankLabel: UILabel!
    
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    
    
    @IBOutlet weak var commentCountLabel: UILabel!
    
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    
   
    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        topicImageView.layer.cornerRadius = 5
        topicImageView.clipsToBounds = true
        
    
        timeStampLabel.textColor = UIColor(red: 0.502, green: 0.502, blue: 0.502, alpha: 1)
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }
    @IBAction func like(button: UIButton) {
        self.delegate?.didTapLikeButton(tableViewCell: self, button: button)
    }
    
    @IBAction func openMenu(button: UIButton) {
        self.delegate?.didTapMenuButton(tableViewCell: self, button: button)
    }
    
    @IBAction func showComments(button: UIButton) {
        self.delegate?.didTapCommentsButton(tableViewCell: self, button: button)
    }

    
}
