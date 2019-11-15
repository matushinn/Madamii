//
//  SettingsViewController.swift
//  Login
//
//  Created by 大江祥太郎 on 2019/10/08.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD


class SettingsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    let settings = [ ["このアプリについて","お問い合わせ","運営会社","利用規約","プライバシーポリシー"],["ログアウト","退会"]]
    

    @IBOutlet weak var settingTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        settingTableView.delegate = self
        settingTableView.dataSource = self
        
        settingTableView.tableFooterView = UIView()
        
    }
    override func viewWillAppear(_ animated: Bool) {
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return settings.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return " "
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return settings[section].count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = settings[indexPath.section][indexPath.row]
        
        cell.accessoryType = .disclosureIndicator
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選ばれた投稿を一時的に格納
      
        switch indexPath.section{
        case 0:
            switch indexPath.row{
            case 0:
                self.performSegue(withIdentifier: "One", sender: nil)
            case 1:
                self.performSegue(withIdentifier: "Two", sender: nil)
                
            case 2:
                self.performSegue(withIdentifier: "Three", sender: nil)
            case 3:
                self.performSegue(withIdentifier: "Four", sender: nil)
            case 4:
                self.performSegue(withIdentifier: "Five", sender: nil)
            default:
                break
            }
        case 1:
            switch indexPath.row{
            case 0:
                let alert = UIAlertController(title: "ログアウト", message: "本当にログアウトしますか？", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    NCMBUser.logOutInBackground({ (error) in
                        if error != nil {
                            SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        } else {
                            // ログアウト成功
                            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                            let rootViewController = storyboard.instantiateViewController(withIdentifier: "SignInController")
                            UIApplication.shared.keyWindow?.rootViewController = rootViewController
                            
                            // ログイン状態の保持
                            let ud = UserDefaults.standard
                            ud.set(false, forKey: "isLogin")
                            ud.synchronize()
                        }
                    })
                })
                
                let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                })
                
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                
            case 1:
                let alert = UIAlertController(title: "会員登録の解除", message: "本当に退会しますか？退会した場合、再度このアカウントをご利用頂くことができません。", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    // ユーザーのアクティブ状態をfalseに
                    if let user = NCMBUser.current() {
                        user.setObject(false, forKey: "active")
                        user.saveInBackground({ (error) in
                            if error != nil {
                                SVProgressHUD.showError(withStatus: error!.localizedDescription)
                            } else {
                                // userのアクティブ状態を変更できたらログイン画面に移動
                                let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                                let rootViewController = storyboard.instantiateViewController(withIdentifier: "SignInController")
                                UIApplication.shared.keyWindow?.rootViewController = rootViewController
                                
                                // ログイン状態の保持
                                let ud = UserDefaults.standard
                                ud.set(false, forKey: "isLogin")
                                ud.synchronize()
                            }
                        })
                    } else {
                        // userがnilだった場合ログイン画面に移動
                        let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                        let rootViewController = storyboard.instantiateViewController(withIdentifier: "SignInController")
                        UIApplication.shared.keyWindow?.rootViewController = rootViewController
                        
                        // ログイン状態の保持
                        let ud = UserDefaults.standard
                        ud.set(false, forKey: "isLogin")
                        ud.synchronize()
                    }
                    
                })
                
                let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                })
                
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            default:
                break
        
            }
        default:
            break
        }
        // 選択状態の解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

}
