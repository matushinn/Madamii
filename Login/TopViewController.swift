//
//  TopViewController.swift
//  Login
//
//  Created by 大江祥太郎 on 2019/07/04.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit

class TopViewController: UIViewController {

    
    @IBOutlet weak var signUp: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //角丸サイズ
        signUp.layer.cornerRadius = 10.0
    }
    

    

}
