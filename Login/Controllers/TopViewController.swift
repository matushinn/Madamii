//
//  TopViewController.swift
//  Login
//
//  Created by 大江祥太郎 on 2019/07/04.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit
import Pastel

class TopViewController: UIViewController {
    
    @IBOutlet weak var signUp: UIButton!
    @IBOutlet weak var login: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //ナビゲーションアイテムのタイトルに画像を設定する。
        self.navigationItem.titleView = UIImageView(image:UIImage(named:"madamii_head"))
        //角丸サイズ
        signUp.layer.cornerRadius = 10.0
        //角丸サイズ
        login.layer.cornerRadius = 10.0
    }
    
    
}
