//
//  servieTermsViewController.swift
//  Login
//
//  Created by 大江祥太郎 on 2019/11/02.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit

class servieTermsViewController: UIViewController {

    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    var serviceCheck:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        checkButton.setImage(UIImage(named: "check-outline"), for: .normal)
        confirmButton.isEnabled = false
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let createVC = segue.destination as! SignUpViewController
        createVC.serviceCheck = self.serviceCheck
        
    }
    @IBAction func check(_ sender: UIButton) {
        if  self.serviceCheck == false{
            checkButton.setImage(UIImage(named: "check-fill"), for: .normal)
            self.serviceCheck = true
            confirmButton.isEnabled = true
        }else{
            checkButton.setImage(UIImage(named: "check-outline"), for: .normal)
            self.serviceCheck = false
        }
    }
    @IBAction func confirm(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
