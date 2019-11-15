//
//  CommentsReplyViewController.swift
//  Login
//
//  Created by 大江祥太郎 on 2019/10/08.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD

class CommentsReplyViewController: UIViewController,UITextViewDelegate {
    
    var postId: String!
    
    var replys = [Reply]()
    
    @IBOutlet weak var replyNameLabel: UILabel!
    @IBOutlet weak var replyTextField: UITextView!
    @IBOutlet weak var confirmButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        replyTextField.delegate = self
        confirmButton.isEnabled = false
        let user = NCMBUser.current()
        
        if user?.object(forKey: "displayName") != nil{
            replyNameLabel.text = user?.object(forKey: "displayName") as! String
            
        }else{
            replyNameLabel.text = "匿名"
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
        if replyTextField.text.count > 0 {
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
                replyNameLabel.text = user?.object(forKey: "displayName") as! String
                
            }else{
                replyNameLabel.text = "匿名"
            }
        }else if sender.isOn == false{
            replyNameLabel.text = "匿名"
        }
    }
    @IBAction func toConfirm(_ sender: Any) {
        SVProgressHUD.show()
        if replyTextField.text.count == 0 {
            
            return
        }
        let object = NCMBObject(className: "Reply")
        object?.setObject(self.postId, forKey: "postId")
        object?.setObject(NCMBUser.current(), forKey: "user")
        object?.setObject(self.replyTextField?.text, forKey: "text")
        object?.setObject(self.replyNameLabel.text, forKey: "userCheck")
        object?.saveInBackground({ (error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                SVProgressHUD.dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.navigationController?.popViewController(animated: true)
                }
                
            }
        })
    }
    
    
    
    
}
