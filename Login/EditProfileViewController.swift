//
//  EditProfileViewController.swift
//  Login
//
//  Created by 大江祥太郎 on 2019/07/04.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit
import NCMB
import NYXImagesKit

class EditProfileViewController: UIViewController,UITextViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userIdTextField:UITextField!
    
    @IBOutlet weak var userNameTextField: UITextField!
    
    @IBOutlet weak var introductionTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //丸くするコード
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        
        userIdTextField.delegate = self
        userNameTextField.delegate = self
        introductionTextView.delegate = self
        
        let userId = NCMBUser.current()?.userName
        userIdTextField.text = userId

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        //リサイズ
        let resizedImage = selectedImage.scale(byFactor: 0.4)
        
        
        picker.dismiss(animated: true, completion: nil)
        
        //data型に変換
        let data = resizedImage!.pngData()
        
        //型を変換
        let file = NCMBFile.file(withName: NCMBUser.current()?.objectId,data:data) as! NCMBFile
        
        file.saveInBackground({ (error) in
            if error != nil{
                print(error)
            }else{
                self.userImageView.image = selectedImage
                
            }
        }) { (progress) in
            print(progress)
        }
        
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectImage(_ sender: Any) {
        
        let alertController = UIAlertController(title: "画像の選択", message: "選択してください", preferredStyle:.actionSheet)
        
        let cameraAction = UIAlertAction(title: "カメラ", style: .default) { (action) in
            // カメラ起動
            //カメラが使えたら
            if UIImagePickerController.isSourceTypeAvailable(.camera) == true {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.allowsEditing = true
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではカメラが使用出来ません。")
            }
        }
        let albumAction = UIAlertAction(title: "フォトライブラリ", style: .default) { (action) in
            // アルバム起動
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == true {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.allowsEditing = true
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではフォトライブラリが使用出来ません。")
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(cameraAction)
        alertController.addAction(albumAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    

}
