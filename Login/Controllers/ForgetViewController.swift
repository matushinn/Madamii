//
//  ForgetViewController.swift
//  Login
//
//  Created by 大江祥太郎 on 2019/10/31.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD

class ForgetViewController: UIViewController , UITextFieldDelegate{

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var searchButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    func textFieldDidChange(_ textView: UITextView) {
        confirmContent()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    func confirmContent() {
        if emailTextField.text!.count > 0 {
            searchButton.isEnabled = true
            SVProgressHUD.dismiss()
        }else{
            SVProgressHUD.dismiss()
            searchButton.isEnabled = false
        }
        
    }
    @IBAction func search(_ sender: Any) {
        if emailTextField.text == "" {
            return
        }
        let query = NCMBUser.query()
       
        NCMBUser.requestPasswordResetForEmail(inBackground: self.emailTextField.text!) { (error) in
            if error != nil{
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            }else{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    // 0.5秒後に実行したい処理
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
 
       
        
    }
    
}
