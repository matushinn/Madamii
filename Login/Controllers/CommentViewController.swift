//
//  CommentViewController.swift
//  Login
//
//  Created by 大江祥太郎 on 2019/07/17.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD
import Kingfisher
import SwiftDate
import GoogleMobileAds
import MessageUI

class CommentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CommentsTableViewCellDelegate, MFMailComposeViewControllerDelegate{
    
    
    var seg_change = 0
    
    var postId: String!
    
    var comments = [Comment]()
    var posts = [Post]()
    
    var flag = 0
    
    var selectedPost: Post?
    var selectedComment: Comment?
    
    var userCheck = ""
    
    var replyOfCount = 0
    
    var shareImage = UIImage()
    
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var commentTableView: UITableView!
    
    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var commentsCountLabel: UILabel!
    
    @IBOutlet weak var setUrlButton: UIButton!
    
    @IBOutlet weak var postNameLabel: UILabel!
    @IBOutlet weak var postTimeLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTableView.dataSource = self
        commentTableView.delegate = self
        
        commentTableView.tableFooterView = UIView()
        
        
        let nib = UINib(nibName: "CommentsTableViewCell", bundle: Bundle.main)
        commentTableView.register(nib, forCellReuseIdentifier: "CommentCell")
        
        //tableviewの長さによって変更できる
        commentTableView.estimatedRowHeight = 120
        
        
        commentTableView.rowHeight = UITableView.automaticDimension
        //loadComments()
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPostComments" {
            let postsCommentViewController = segue.destination as! PostCommentsViewController
            postsCommentViewController.postId = postId
            
        }
        if segue.identifier == "toReply" {
            let replyViewController = segue.destination as! ReplyViewController
            replyViewController.commentId = selectedComment?.objectId
            replyViewController.selectedComment = selectedComment
            
        }
        if segue.identifier == "toUrl" {
            let companyVC = segue.destination as! CompanyViewController
            if selectedPost?.postUrl != "" {
                companyVC.url = URL(string:selectedPost!.postUrl)
            }
        }
        if segue.identifier == "toReplyComment" {
            let commentsReplyVC = segue.destination as! CommentsReplyViewController
            commentsReplyVC.postId = selectedComment?.objectId
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        loadPost()
        loadComments()
        
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
    
    func loadPost(){
        
        postNameLabel.text = selectedPost?.userCheck
        postLabel.text = selectedPost?.text
        
        if selectedPost?.postUrl != "" {
            setUrlButton.setTitle("関連記事のURLへ",for: .normal)
           setUrlButton.isEnabled = true
        }else{
            setUrlButton.setTitle("関連記事のURL:(なし)", for: .normal)
            setUrlButton.isEnabled = false
        }
        
        let imageUrl = selectedPost?.imageUrl
        postImageView.kf.setImage(with: URL(string: imageUrl!), placeholder: UIImage(named: "placeholder.jpg"))
        self.shareImage = postImageView.image!
        // タイムスタンプ(投稿日時) (※フォーマットのためにSwiftDateライブラリをimport)
        //日付のフォーマットを指定する。
        let format = DateFormatter()
        format.dateFormat = "yyyy/MM/dd HH:mm"
        //日付をStringに変換する
        let sDate = format.string(from: selectedPost!.createDate)
        postTimeLabel.text = sDate
        
        
        commentsCountLabel.text = String(selectedPost!.commentsCount)+"件"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func didTapReplyButton(tableViewCell: UITableViewCell, button: UIButton) {
        
        // 選ばれた投稿を一時的に格納
        selectedComment = comments[tableViewCell.tag]
    
        self.performSegue(withIdentifier: "toReplyComment", sender: nil)
 
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選ばれた投稿を一時的に格納
        selectedComment = comments[indexPath.row]
        
        // 選択状態の解除
        tableView.deselectRow(at: indexPath, animated: true)
        // 遷移させる(このとき、prepareForSegue関数で値を渡す)
        self.performSegue(withIdentifier: "toReply", sender: nil)
    }
    
    func didTapGoodButton(tableViewCell: UITableViewCell, button: UIButton) {
        if comments[tableViewCell.tag].isLiked == false || comments[tableViewCell.tag].isLiked == nil  {
            let query = NCMBQuery(className: "Comment")
            query?.getObjectInBackground(withId: comments[tableViewCell.tag].objectId, block: { (post, error) in
                post?.addUniqueObject(NCMBUser.current().objectId, forKey: "likeUser")
                post?.saveEventually({ (error) in
                    if error != nil {
                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    } else {
                        self.loadComments()
                    }
                })
            })
        } else {
            let query = NCMBQuery(className: "Comment")
            query?.getObjectInBackground(withId: comments[tableViewCell.tag].objectId, block: { (post, error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                } else {
                    post?.removeObjects(in: [NCMBUser.current().objectId], forKey: "likeUser")
                    post?.saveEventually({ (error) in
                        if error != nil {
                            SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        } else {
                            self.loadComments()
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
            let query = NCMBQuery(className: "Comment")
            query?.getObjectInBackground(withId: self.comments[tableViewCell.tag].objectId, block: { (comment, error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                } else {
                    // 取得した投稿オブジェクトを削除
                    comment?.deleteInBackground({ (error) in
                        if error != nil {
                            SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        } else {
                            // 再読込
                            self.loadComments()
                            SVProgressHUD.dismiss()
                        }
                    })
                }
            })
        }
        let reportAction = UIAlertAction(title: "報告する", style: .destructive) { (action) in
            /*
            //メールを送信できるかチェック
            if MFMailComposeViewController.canSendMail()==false {
                print("Email Send Failed")
                return
            }
            
            var mailViewController = MFMailComposeViewController()
            var toRecipients = ["infoboard1115@gmail.com"]
            
            
            mailViewController.mailComposeDelegate = self
            mailViewController.setSubject("コメント機能での通報")
            mailViewController.setToRecipients(toRecipients) //Toアドレスの表示
            
            mailViewController.setMessageBody(self.comments[tableViewCell.tag].user.userName+"さんのコメントを通報する", isHTML: false)
            
            self.present(mailViewController, animated: true, completion: nil)
 */
            SVProgressHUD.showSuccess(withStatus: "この投稿を報告しました。ご協力ありがとうございました。")
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        if comments[tableViewCell.tag].user.objectId == NCMBUser.current().objectId {
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
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentsTableViewCell
        
        cell.delegate = self
        cell.tag = indexPath.row
        
        //let user = comments[indexPath.row].user
        
        cell.commentLabel.text = comments[indexPath.row].text
        // Likeによってハートの表示を変える
        if comments[indexPath.row].isLiked == true {
            cell.goodButton.setImage(UIImage(named: "heart-fill"), for: .normal)
        } else {
            cell.goodButton.setImage(UIImage(named: "heart-outline"), for: .normal)
        }
        
        if  comments[indexPath.row].likeCount == 0{
            cell.likeCountLabel.text = "0件"
        }else{
            // goodの数
            cell.likeCountLabel.text = "\(comments[indexPath.row].likeCount)件"
        }
        
        if comments[indexPath.row].user.objectId == NCMBUser.current().objectId {
            // 自分の投稿なので、削除ボタンを出す
            cell.menuButton.setTitle("削除", for: .normal)
        } else {
            // 他人の投稿なので、報告ボタンを出す
            cell.menuButton.setTitle("通報", for: .normal)
        }
        cell.nameLabel.text = comments[indexPath.row].userCheck
        //日付のフォーマットを指定する。
        let format = DateFormatter()
        format.dateFormat = "MM/dd HH:mm"
        //日付をStringに変換する
        let sDate = format.string(from: comments[indexPath.row].createDate)
        cell.timeLabel.text = sDate
        // タイムスタンプ(投稿日時) (※フォーマットのためにSwiftDateライブラリをimport)
        //cell.timeLabel.text = comments[indexPath.row].createDate.toString()
        
        cell.replyCountLabel.text = "\(comments[indexPath.row].replyCount)件の返信"
        
        return cell
    }
    
    func loadComments() {
        comments = [Comment]()
        let query = NCMBQuery(className: "Comment")
        // 降順
        if self.seg_change == 0 {
            query?.order(byDescending: "createDate")
        }else if self.seg_change == 1{
            query?.order(byDescending: "ReplysCount")
        }
        
        
        query?.whereKey("postId", equalTo: postId)
        query?.includeKey("user")
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                for commentObject in result as! [NCMBObject] {
                    
                    // コメントをしたユーザーの情報を取得
                    let user = commentObject.object(forKey: "user") as! NCMBUser
                    let userModel = User(objectId: user.objectId, userName: user.userName)
                    userModel.displayName = user.object(forKey: "displayName") as? String
                    
                    // コメントの文字を取得
                    let text = commentObject.object(forKey: "text") as! String
                    if commentObject.object(forKey: "ReplysCount") != nil{
                        self.replyOfCount = commentObject.object(forKey: "ReplysCount") as! Int
                    }else{
                        self.replyOfCount = 0
                    }
                    if commentObject.object(forKey: "userCheck") != nil{
                        self.userCheck = commentObject.object(forKey: "userCheck") as! String
                        
                    }else{
                        self.userCheck = "匿名"
                    }
                    // Commentクラスに格納
                    let comment = Comment(postId: self.postId,objectId: commentObject.objectId, user: userModel, text: text, userCheck:self.userCheck,replyCount:self.replyOfCount,createDate: commentObject.createDate)
                    
                    let commentsUsers = commentObject.object(forKey: "commentsUser") as? [String]
                    
                    // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
                    let likeUsers = commentObject.object(forKey: "likeUser") as? [String]
                    if likeUsers?.contains(NCMBUser.current().objectId) == true {
                        comment.isLiked = true
                    } else {
                        comment.isLiked = false
                    }
                    
                    // いいねの件数
                    if let likes = likeUsers {
                        comment.likeCount = likes.count
                    }
                    
                    // コメントの件数
                    if let comments = commentsUsers {
                        comment.commentsCount = comments.count
                    }
                    
                    
                    self.comments.append(comment)
                    
                    
                    // テーブルをリロード
                    self.commentTableView.reloadData()
                }
                
            }
            // post数を表示
            self.commentsCountLabel.text = "コメント"+String(self.comments.count)+"件"
            
            let queries = NCMBQuery(className: "Post")
            
            // Postとの認証
            queries?.whereKey("objectId", equalTo: self.postId)
            
            // オブジェクトの取得
            queries?.findObjectsInBackground({ (result, error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                } else {
                    let messages = result as! [NCMBObject]
                    let textObject = messages.first
                    textObject?.setObject(self.comments.count, forKey: "CommentsCount")
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
    
    
    @IBAction func commentChange(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        //選択されたインデックスの文字列を取得してラベルに設定
        switch selectedIndex {
        case 0:
            self.seg_change = 0
        case 1:
            self.seg_change = 1
        default:
            break
        }
        loadComments()
        
    }
    
    
    @IBAction func addComment() {
        self.performSegue(withIdentifier: "toPostComments", sender: nil)
    }
    
    @IBAction func toUrl(_ sender: Any) {
        self.performSegue(withIdentifier: "toUrl", sender: nil)
    }
    
}

