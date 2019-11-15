//
//  ReplyViewController.swift
//  Login
//
//  Created by 大江祥太郎 on 2019/10/08.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit
import NCMB
import Kingfisher
import SVProgressHUD
import SwiftDate


class ReplyViewController: UIViewController , UITableViewDataSource, UITableViewDelegate,ReplyTableViewCellDelegate{
    
    
    @IBOutlet weak var replyTableView: UITableView!
    
    @IBOutlet weak var commentNameLabel: UILabel!
    @IBOutlet weak var commentTimeLabel: UILabel!
    
    
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    var commentId: String!
    
    var selectedComment: Comment?
    
    var replys = [Reply]()
    
    var followings = [NCMBUser]()
    
    var userCheck = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        replyTableView.dataSource = self
        replyTableView.delegate = self
        
        let nib = UINib(nibName: "ReplyTableViewCell", bundle: Bundle.main)
        replyTableView.register(nib, forCellReuseIdentifier: "ReplyCell")
        
        replyTableView.tableFooterView = UIView()
        
        //tableviewの長さによって変更できる
        replyTableView.estimatedRowHeight = 95
        
        
        replyTableView.rowHeight = UITableView.automaticDimension
    }
    override func viewWillAppear(_ animated: Bool) {
    
        loadComment()
        loadReply()
        
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toReplyComment" {
            let commentsReplyVC = segue.destination as! CommentsReplyViewController
            commentsReplyVC.postId = selectedComment?.objectId
            
        }
        
    }
    func loadComment(){
        commentNameLabel.text = selectedComment?.userCheck
        commentLabel.text = selectedComment?.text
        // タイムスタンプ(投稿日時) (※フォーマットのためにSwiftDateライブラリをimport)
        //日付のフォーマットを指定する。
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd HH:mm"
        //日付をStringに変換する
        let sDate = format.string(from: selectedComment!.createDate)
        commentTimeLabel.text = sDate
        //commentTimeLabel.text = selectedComment?.createDate.toString()
        
        commentCountLabel.text = "返信"+String(selectedComment!.commentsCount)+"件"
    }
    
    func didTapGoodButton(tableViewCell: UITableViewCell, button: UIButton) {
        if replys[tableViewCell.tag].isLiked == false || replys[tableViewCell.tag].isLiked == nil {
            let query = NCMBQuery(className: "Reply")
            query?.getObjectInBackground(withId: replys[tableViewCell.tag].objectId, block: { (post, error) in
                post?.addUniqueObject(NCMBUser.current().objectId, forKey: "likeUser")
                post?.saveEventually({ (error) in
                    if error != nil {
                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    } else {
                        self.loadReply()
                    }
                })
            })
        } else {
            let query = NCMBQuery(className: "Reply")
            query?.getObjectInBackground(withId: replys[tableViewCell.tag].objectId, block: { (post, error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                } else {
                    post?.removeObjects(in: [NCMBUser.current().objectId], forKey: "likeUser")
                    post?.saveEventually({ (error) in
                        if error != nil {
                            SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        } else {
                            self.loadReply()
                        }
                    })
                }
            })
        }
    }
    
    func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "削除する", style: .destructive) { (action) in
            SVProgressHUD.show()
            let query = NCMBQuery(className: "Reply")
            query?.getObjectInBackground(withId: self.replys[tableViewCell.tag].objectId, block: { (reply, error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                } else {
                    // 取得した投稿オブジェクトを削除
                    reply?.deleteInBackground({ (error) in
                        if error != nil {
                            SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        } else {
                            // 再読込
                            self.loadReply()
                            SVProgressHUD.dismiss()
                        }
                    })
                }
            })
        }
        let reportAction = UIAlertAction(title: "報告する", style: .destructive) { (action) in
            SVProgressHUD.showSuccess(withStatus: "この投稿を報告しました。ご協力ありがとうございました。")
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        if replys[tableViewCell.tag].user.objectId == NCMBUser.current().objectId {
            // 自分の投稿なので、削除ボタンを出す
            alertController.addAction(deleteAction)
        } else {
            // 他人の投稿なので、報告ボタンを出す
            alertController.addAction(reportAction)
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReplyCell") as! ReplyTableViewCell
        
        cell.delegate = self
        cell.tag = indexPath.row
        
        let user = replys[indexPath.row].user
        cell.nameLabel.text = user.displayName
        
        //userImageView.sd_setImage(with: URL(string: userImagePath))
        //userImageView.kf.setImage(with: URL(string: userImagePath))
        
        cell.replyLabel.text = replys[indexPath.row].text
        // Likeによってハートの表示を変える
        if replys[indexPath.row].isLiked == true {
            cell.goodButton.setImage(UIImage(named: "heart-fill"), for: .normal)
        } else {
            cell.goodButton.setImage(UIImage(named: "heart-outline"), for: .normal)
        }
        
        if  replys[indexPath.row].likeCount == 0{
            cell.goodCountLabel.text = "0件"
        }else{
            // goodの数
            cell.goodCountLabel.text = "\(replys[indexPath.row].likeCount)件"
        }
       
        if replys[indexPath.row].user.objectId == NCMBUser.current().objectId {
            // 自分の投稿なので、削除ボタンを出す
            cell.menuButton.setTitle("削除", for: .normal)
        } else {
            // 他人の投稿なので、報告ボタンを出す
            cell.menuButton.setTitle("通報", for: .normal)
        }
        //日付のフォーマットを指定する。
        let format = DateFormatter()
        format.dateFormat = "MM/dd HH:mm"
        //日付をStringに変換する
        let sDate = format.string(from: replys[indexPath.row].createDate)
        cell.timeLabel.text = sDate
       
        return cell
    }
    
    func loadReply() {
        replys = [Reply]()
        let query = NCMBQuery(className: "Reply")
        // 降順
        query?.order(byDescending: "createDate")
        
        query?.whereKey("postId", equalTo: commentId)
        query?.includeKey("user")
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                for replyObject in result as! [NCMBObject] {
                    
                    // コメントをしたユーザーの情報を取得
                    let user = replyObject.object(forKey: "user") as! NCMBUser
                    let userModel = User(objectId: user.objectId, userName: user.userName)
                    userModel.displayName = user.object(forKey: "displayName") as? String
                    
                    // コメントの文字を取得
                    let text = replyObject.object(forKey: "text") as! String
                    
                    if replyObject.object(forKey: "userCheck") != nil{
                        self.userCheck = replyObject.object(forKey: "userCheck") as! String
                    }else{
                        self.userCheck = "匿名"
                    }
                    // Commentクラスに格納
                    let reply = Reply(postId: self.commentId,objectId: replyObject.objectId, user: userModel, text: text,userCheck:self.userCheck,createDate: replyObject.createDate)
                    
                    let replysUser = replyObject.object(forKey: "commentsUser") as? [String]
                    
                    // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
                    let likeUsers = replyObject.object(forKey: "likeUser") as? [String]
                    if likeUsers?.contains(NCMBUser.current().objectId) == true {
                        reply.isLiked = true
                    } else {
                        reply.isLiked = false
                    }
                    let badUsers = replyObject.object(forKey: "badUser") as? [String]
                    if badUsers?.contains(NCMBUser.current().objectId) == true {
                        reply.isBad = true
                    } else {
                        reply.isBad = false
                    }
                    
                    // いいねの件数
                    if let likes = likeUsers {
                        reply.likeCount = likes.count
                    }
                    // いいねの件数
                    if let bad = badUsers {
                        reply.badCount = bad.count
                    }
                   
                    // コメントの件数
                    if let replys = replysUser {
                        reply.commentsCount = replys.count
                    }
                    self.replys.append(reply)
                    
                    
                    // テーブルをリロード
                    self.replyTableView.reloadData()
                }
            
            }
            // post数を表示
            self.commentCountLabel.text = "返信"+String(self.replys.count)+"件"
            
            let queries = NCMBQuery(className: "Comment")
            
            // Postとの認証
            queries?.whereKey("objectId", equalTo: self.commentId)
            
            // オブジェクトの取得
            queries?.findObjectsInBackground({ (result, error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                } else {
                    let messages = result as! [NCMBObject]
                    let textObject = messages.first
                    textObject?.setObject(self.replys.count, forKey: "ReplysCount")
                    //保存できるかどうか
                    textObject?.saveInBackground({ (error) in
                        if error != nil{
                            SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        }else{
                            
                        }
                    })
                }
                
                
            })
        })
    }
    
    @IBAction func load(_ sender: Any) {
        self.loadReply()
    }
    
    @IBAction func addReply() {
        self.performSegue(withIdentifier: "toReplyComment", sender: nil)
    }
}

    


