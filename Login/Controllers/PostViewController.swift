//
//  PostViewController.swift
//  Login
//
//  Created by 大江祥太郎 on 2019/07/07.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit
import NYXImagesKit
import NCMB
import SVProgressHUD
import UITextView_Placeholder

class PostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {
    
    let noImage = UIImage(named: "no-image")
    
    var resizedImage: UIImage!
    
    var postURL:String?
    
    var postId: String!
    
    @IBOutlet var postImageView: UIImageView!
    
    @IBOutlet var titleTextView: UITextView!
    @IBOutlet weak var commentTextView: UITextView!
    
    @IBOutlet var confirmButton: UIBarButtonItem!
    @IBOutlet weak var postNameLabel: UILabel!
    
    @IBOutlet weak var nameSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postImageView.image = noImage
        
        confirmButton.isEnabled = false
        titleTextView.placeholder = "54文字以下のタイトルを書く"
        titleTextView.delegate = self
        commentTextView.delegate = self
        
        //postNameLabel.text = NCMBUser.current()
    }
    override func viewWillAppear(_ animated: Bool) {
        let user = NCMBUser.current()
        
        if user?.object(forKey: "displayName") != nil{
            postNameLabel.text = user?.object(forKey: "displayName") as! String
            
        }else{
            postNameLabel.text = "匿名"
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        resizedImage = selectedImage.scale(byFactor: 0.3)
        
        postImageView.image = resizedImage
        
        picker.dismiss(animated: true, completion: nil)
        
        confirmContent()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        confirmContent()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    @IBAction func selectImage() {
        let alertController = UIAlertController(title: "画像選択", message: "シェアする画像を選択して下さい。", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        let cameraAction = UIAlertAction(title: "カメラで撮影", style: .default) { (action) in
            // カメラ起動
            if UIImagePickerController.isSourceTypeAvailable(.camera) == true {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではカメラが使用出来ません。")
            }
        }
        
        let photoLibraryAction = UIAlertAction(title: "フォトライブラリから選択", style: .default) { (action) in
            // アルバム起動
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == true {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではフォトライブラリが使用出来ません。")
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(cameraAction)
        alertController.addAction(photoLibraryAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func nameSwitch(_ sender: UISwitch) {
        if sender.isOn {
            let user = NCMBUser.current()
            if user?.object(forKey: "displayName") != nil{
                postNameLabel.text = user?.object(forKey: "displayName") as! String
            }else{
                postNameLabel.text = "匿名"
            }
        }else if sender.isOn == false{
            postNameLabel.text = "匿名"
        }
    }
    
    @IBAction func confirm() {
        if titleTextView.text.count == 0 {
            SVProgressHUD.show(withStatus: "コメントを入力してください")
            return
        }
        if postImageView.image == noImage {
            resizedImage = noImage
        }
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
                
                if self.postURL != nil{
                    postObject?.setObject(self.postURL, forKey: "postUrl")
                }
                
                postObject?.setObject(self.titleTextView.text!, forKey: "text")
                postObject?.setObject(self.commentTextView.text!, forKey: "comment")
                postObject?.setObject(NCMBUser.current(), forKey: "user")
                postObject?.setObject(self.postNameLabel.text, forKey: "userCheck")
                let url = "https://mbaas.api.nifcloud.com/2013-09-01/applications/VxTyCpwvfQh2qccF/publicFiles/" + file.name
                postObject?.setObject(url, forKey: "imageUrl")
                self.postId = postObject?.objectId
                postObject?.saveInBackground({ (error) in
                    if error != nil {
                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    } else {
                        let object = NCMBObject(className: "Comment")
                        object?.setObject(postObject?.objectId, forKey: "postId")
                        object?.setObject(NCMBUser.current(), forKey: "user")
                        object?.setObject(self.postNameLabel.text, forKey: "userCheck")
                        object?.setObject(self.commentTextView.text, forKey: "text")
                        object?.saveInBackground({ (error) in
                            if error != nil {
                                SVProgressHUD.showError(withStatus: error!.localizedDescription)
                            } else {
                                SVProgressHUD.dismiss()
                                self.postImageView.image = nil
                                self.postImageView.image = self.noImage
                                self.titleTextView.text = nil
                                self.postURL = nil
                                self.commentTextView.text = nil
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    self.navigationController?.popViewController(animated: true)
                                }
                                
                            }
                        })
                        
                        
                    }
                })
            }
        }) { (progress) in
            print(progress)
        }
        
    }
    
    func confirmContent() {
        if commentTextView.text.count > 0 && titleTextView.text.count > 0 && titleTextView.text.count <= 54{
            confirmButton.isEnabled = true
            SVProgressHUD.dismiss()
        } else if titleTextView.text.count > 54{
            SVProgressHUD.show(withStatus: "文字数オーバーです")
            confirmButton.isEnabled = false
        }else{
            SVProgressHUD.dismiss()
            confirmButton.isEnabled = false
        }
        
    }
    
    
    @IBAction func setURL(_ sender: Any) {
        let alert = UIAlertController(title: "URLの入力", message: "URLを挿入すると実際に本文に表示されます。", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            if let textFields = alert.textFields {
                
                // アラートに含まれるすべてのテキストフィールドを調べる
                for textField in textFields {
                    self.postURL = textField.text!
                }
            }else{
                self.postURL = nil
            }
            alert.dismiss(animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) in
            self.postURL = nil
            alert.dismiss(animated: true, completion: nil)
        })
       
        alert.addTextField { (textField) in
            textField.placeholder = "URLを入力"
            
        }
        
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
       
        self.present(alert, animated: true, completion: nil)
    }
 
    @IBAction func cancel() {
        if titleTextView.isFirstResponder == true {
            titleTextView.resignFirstResponder()
        }
        
        let alert = UIAlertController(title: "投稿内容の破棄", message: "入力中の投稿内容を破棄しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.titleTextView.text = nil
            self.postImageView.image = UIImage(named: "photo-placeholder")
            self.confirmContent()
        self.navigationController?.popViewController(animated: true)
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        })
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
}
