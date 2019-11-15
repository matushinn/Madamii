//
//  CommentsTableViewCell.swift
//  Login
//
//  Created by 大江祥太郎 on 2019/10/04.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit
//共通化
protocol CommentsTableViewCellDelegate {
    func didTapGoodButton(tableViewCell: UITableViewCell, button: UIButton)
    func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton)
    func didTapReplyButton(tableViewCell: UITableViewCell, button: UIButton)
}
class CommentsTableViewCell: UITableViewCell {

    var delegate: CommentsTableViewCellDelegate?
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var likeCountLabel: UILabel!
    
    
    @IBOutlet weak var goodButton: UIButton!
    
   
    @IBOutlet weak var menuButton: UIButton!
    
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var replyCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
   
    @IBAction func good(_ sender: UIButton) {
        self.delegate?.didTapGoodButton(tableViewCell: self, button: goodButton)
        
    }
    
    
    @IBAction func openMenu(_ sender: UIButton) {
        self.delegate?.didTapMenuButton(tableViewCell: self, button: menuButton)
    }
    @IBAction func toReply(_ sender: UIButton) {
        self.delegate?.didTapReplyButton(tableViewCell: self, button: replyButton)
    }
    
}
