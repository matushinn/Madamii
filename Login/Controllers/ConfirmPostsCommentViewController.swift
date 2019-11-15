//
//  ConfirmPostsCommentViewController.swift
//  Login
//
//  Created by 大江祥太郎 on 2019/10/12.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD

class ConfirmPostsCommentViewController: UIViewController {
    var postId: String!
    var commentsText = ""
    var userCheck = ""
    
    @IBOutlet weak var commentsNameLabel: UILabel!
    @IBOutlet weak var commentsTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        commentsNameLabel.text = userCheck
        commentsTextView.text = commentsText
    }
    
    @IBAction func confirm(_ sender: Any) {
        let object = NCMBObject(className: "Comment")
        object?.setObject(self.postId, forKey: "postId")
        object?.setObject(NCMBUser.current(), forKey: "user")
        object?.setObject(self.commentsNameLabel.text, forKey: "userCheck")
        object?.setObject(self.commentsText, forKey: "text")
        object?.saveInBackground({ (error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                //SVProgressHUD.dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    // 0.5秒後に実行したい処理
                    self.tabBarController?.selectedIndex = 1
                }
                
            }
        })
        
        
    }
    
    
}
