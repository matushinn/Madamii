//
//  ConfirmCommentsReplyViewController.swift
//  Login
//
//  Created by 大江祥太郎 on 2019/10/12.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD

class ConfirmCommentsReplyViewController: UIViewController {
    var postId: String!
    var commentsText = ""
    var userCheck = ""
    
    @IBOutlet weak var replyNameLabel: UILabel!
    @IBOutlet weak var replyTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        replyNameLabel.text = userCheck
        replyTextView.text = commentsText
    }
    
    @IBAction func confirm(_ sender: Any) {
        let object = NCMBObject(className: "Reply")
        object?.setObject(self.postId, forKey: "postId")
        object?.setObject(NCMBUser.current(), forKey: "user")
        object?.setObject(self.replyTextView?.text, forKey: "text")
        object?.setObject(self.replyNameLabel.text, forKey: "userCheck")
        object?.saveInBackground({ (error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    // 0.5秒後に実行したい処理
                    self.tabBarController?.selectedIndex = 1
                }
                
            }
        })
        
        
    }
    
    

    
}
