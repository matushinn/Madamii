//
//  ReplyTableViewCell.swift
//  Login
//
//  Created by 大江祥太郎 on 2019/10/08.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit

protocol ReplyTableViewCellDelegate {
    func didTapGoodButton(tableViewCell: UITableViewCell, button: UIButton)
    
    func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton)
}
class ReplyTableViewCell: UITableViewCell {

    var delegate: ReplyTableViewCellDelegate?
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var goodCountLabel: UILabel!
   
    @IBOutlet weak var replyLabel: UILabel!
    
   
    @IBOutlet weak var goodButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
   
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
}
