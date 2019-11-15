//
//  CompanyViewController.swift
//  Login
//
//  Created by 大江祥太郎 on 2019/10/13.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit
import NCMB
import WebKit

class CompanyViewController: UIViewController , WKUIDelegate {
    
    var webView: WKWebView!
    //5.URL作って、表示させる！
    var url = URL(string:"http://madamii.com/aboutcompany")
    
    

    override func loadView() {
        super.loadView()
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        
        let myRequest = URLRequest(url: url!)
        webView.load(myRequest)
 
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

}
