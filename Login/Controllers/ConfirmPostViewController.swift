//
//  ConfirmPostViewController.swift
//  Login
//
//  Created by 大江祥太郎 on 2019/10/12.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD
import NYXImagesKit
import UITextView_Placeholder

class ConfirmPostViewController: UIViewController {

    var postId: String!
    var commentsText = ""
    var userCheck = ""
    let noImage = UIImage(named: "no-image")
    var resizedImage = UIImage()
    
    @IBOutlet weak var commentsNameLabel: UILabel!
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        imageView.image = resizedImage
        commentsNameLabel.text = userCheck
        commentsTextView.text = commentsText
    }
    
    @IBAction func confirm(_ sender: Any) {
        SVProgressHUD.show()
        
        // 撮影した画像をデータ化したときに右に90度回転してしまう問題の解消
        UIGraphicsBeginImageContext(resizedImage.size)
        let rect = CGRect(x: 0, y: 0, width: resizedImage.size.width, height: resizedImage.size.height)
        resizedImage.draw(in: rect)
        resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let data = resizedImage.pngData()
        // ここを変更（ファイル名無いので）
        let file = NCMBFile.file(with: data) as! NCMBFile
        
        file.saveInBackground({ (error) in
            if error != nil {
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "画像アップロードエラー", message: error!.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                // 画像アップロードが成功
                let postObject = NCMBObject(className: "Post")
                
               
                postObject?.setObject(self.commentsTextView.text!, forKey: "text")
                postObject?.setObject(NCMBUser.current(), forKey: "user")
                postObject?.setObject(self.commentsNameLabel.text, forKey: "userCheck")
                let url = "https://mbaas.api.nifcloud.com/2013-09-01/applications/VxTyCpwvfQh2qccF/publicFiles/" + file.name
                postObject?.setObject(url, forKey: "imageUrl")
                postObject?.saveInBackground({ (error) in
                    if error != nil {
                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    } else {
                        SVProgressHUD.dismiss()
                        self.imageView.image = nil
                        self.imageView.image = self.noImage
                        self.commentsTextView.text = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            // 0.5秒後に実行したい処理
                            self.tabBarController?.selectedIndex = 1
                        }
                        
                    }
                })
            }
        }) { (progress) in
            print(progress)
        }
        
    
            
        
    }
    

    

}
