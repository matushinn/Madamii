//
//  PostCommentsViewController.swift
//  Login
//
//  Created by 大江祥太郎 on 2019/10/05.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD

class PostCommentsViewController: UIViewController,UITextViewDelegate {

    var postId: String!
    
    var comments = [Comment]()
    
    var userCheck = ""
    
    
    @IBOutlet weak var confirmButton: UIBarButtonItem!
    @IBOutlet weak var commentsTextField: UITextView!
    
    @IBOutlet weak var commentsNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        commentsTextField.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        confirmButton.isEnabled = false
        
        let user = NCMBUser.current()
        
        if user?.object(forKey: "displayName") != nil{
            commentsNameLabel.text = user?.object(forKey: "displayName") as! String
            
        }else{
            commentsNameLabel.text = "匿名"
        }
    }
    func currentUser(){
        if NCMBUser.current() == nil {
            // ログアウト成功
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "SignInController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            
            // ログイン状態の保持
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
        }
    }
    func confirmContent() {
        if commentsTextField.text.count > 0  {
            confirmButton.isEnabled = true
        } else {
            confirmButton.isEnabled = false
        }
    }
    func textViewDidChange(_ textView: UITextView) {
        confirmContent()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
        confirmContent()
    }
    
 
    @IBAction func nameSwitch(_ sender: UISwitch) {
        if sender.isOn {
            let user = NCMBUser.current()
            if user?.object(forKey: "displayName") != nil{
                commentsNameLabel.text = user?.object(forKey: "displayName") as! String
                
            }else{
                commentsNameLabel.text = "匿名"
            }
        }else if sender.isOn == false{
            commentsNameLabel.text = "匿名"
        }
    }
    
    
    @IBAction func post(_ sender: Any) {
        SVProgressHUD.show()
        if commentsTextField.text.count == 0 {
            return
        }
        
        let object = NCMBObject(className: "Comment")
        object?.setObject(self.postId, forKey: "postId")
        object?.setObject(NCMBUser.current(), forKey: "user")
        object?.setObject(self.commentsNameLabel.text, forKey: "userCheck")
        object?.setObject(self.commentsTextField.text, forKey: "text")
        object?.saveInBackground({ (error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                SVProgressHUD.dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    // 0.5秒後に実行したい処理
                    self.navigationController?.popViewController(animated: true)
                }
                
            }
        })
    }
    
    

}
