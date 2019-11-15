//
//  timelineViewController.swift
//  Login
//
//  Created by 大江祥太郎 on 2019/07/07.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit
import NCMB
import Kingfisher
import SVProgressHUD
import SwiftDate

class timelineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TimeLineTableViewCellDelegate,UITabBarDelegate  {
    var selectedPost: Post?
    
    var posts = [Post]()
    
    var comments = [Comment]()

    var commentOfCount = 0
    
    var flag = 0
    
    var userCheck = ""
    
    var postComment = ""
    
    var postUrl = ""
    
    var rankCheck = 0
    
    @IBOutlet var timelineTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timelineTableView.dataSource = self
        timelineTableView.delegate = self
        
        let nib = UINib(nibName: "TimeLineTableViewCell", bundle: Bundle.main)
        timelineTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        
        timelineTableView.tableFooterView = UIView()
        
       
    }
    override func viewWillAppear(_ animated: Bool) {
 
        //ナビゲーションアイテムのタイトルに画像を設定する。
        self.navigationItem.titleView = UIImageView(image:UIImage(named:"madamii_head"))
        
        // 引っ張って更新
        setRefreshControl()
        
        loadTimeline()
        
        
    }
  
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toComments" {
            let commentViewController = segue.destination as! CommentViewController
            commentViewController.postId = selectedPost?.objectId
            commentViewController.selectedPost = selectedPost
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TimeLineTableViewCell
        
        cell.delegate = self
        cell.tag = indexPath.row
        
        cell.commentLabel.text = posts[indexPath.row].text
        let imageUrl = posts[indexPath.row].imageUrl
        cell.topicImageView.kf.setImage(with: URL(string: imageUrl), placeholder: UIImage(named: "no-image.png"))
        
        // Likeによってハートの表示を変える
        if posts[indexPath.row].isLiked == true {
            cell.likeButton.setImage(UIImage(named: "heart-fill"), for: .normal)
        } else {
            cell.likeButton.setImage(UIImage(named: "heart-outline"), for: .normal)
        }
        if posts[indexPath.row].user.objectId == NCMBUser.current().objectId {
            // 自分の投稿なので、削除ボタンを出す
            cell.menuButton.setTitle("削除", for: .normal)
        } else {
            // 他人の投稿なので、報告ボタンを出す
            cell.menuButton.setTitle("通報", for: .normal)
        }
        
        cell.commentRankLabel.text = "\(indexPath.row+1)位"
        //コメントランク
        
        
 
        //日付のフォーマットを指定する。
        let format = DateFormatter()
        format.dateFormat = "MM/dd HH:mm"
        //日付をStringに変換する
        let sDate = format.string(from: posts[indexPath.row].createDate)
        // タイムスタンプ(投稿日時) (※フォーマットのためにSwiftDateライブラリをimport)
        cell.timeStampLabel.text = sDate
        
        cell.commentCountLabel.text = "\(posts[indexPath.row].commentsCount)件"
        
        
        return cell
        
        
    }
    
    func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton) {
        
        if posts[tableViewCell.tag].isLiked == false || posts[tableViewCell.tag].isLiked == nil {
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
                post?.addUniqueObject(NCMBUser.current().objectId, forKey: "likeUser")
                post?.saveEventually({ (error) in
                    if error != nil {
                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    } else {
                        self.loadTimeline()
                    }
                })
            })
        } else {
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                } else {
                    post?.removeObjects(in: [NCMBUser.current().objectId], forKey: "likeUser")
                    post?.saveEventually({ (error) in
                        if error != nil {
                            SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        } else {
                            self.loadTimeline()
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
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: self.posts[tableViewCell.tag].objectId, block: { (post, error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                } else {
                    // 取得した投稿オブジェクトを削除
                    post?.deleteInBackground({ (error) in
                        if error != nil {
                            SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        } else {
                            // 再読込
                            self.loadTimeline()
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
        if posts[tableViewCell.tag].user.objectId == NCMBUser.current().objectId {
            // 自分の投稿なので、削除ボタンを出す
            alertController.addAction(deleteAction)
        } else {
            // 他人の投稿なので、報告ボタンを出す
            alertController.addAction(reportAction)
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton) {
        // 選ばれた投稿を一時的に格納
        selectedPost = posts[tableViewCell.tag]
       
        // 遷移させる(このとき、prepareForSegue関数で値を渡す)
        self.performSegue(withIdentifier: "toComments", sender: nil)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選ばれた投稿を一時的に格納
        selectedPost = posts[indexPath.row]
        
        // 選択状態の解除
        tableView.deselectRow(at: indexPath, animated: true)
        // 遷移させる(このとき、prepareForSegue関数で値を渡す)
        self.performSegue(withIdentifier: "toComments", sender: nil)
    }
    
    
    func loadTimeline() {
        let query = NCMBQuery(className: "Post")
        // 降順
        query?.order(byDescending: "CommentsCount")
        
        // 投稿したユーザーの情報も同時取得
        query?.includeKey("user")
        
        currentUser()
        
        // オブジェクトの取得
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                // 投稿を格納しておく配列を初期化(これをしないとreload時にappendで二重に追加されてしまう)
                self.posts = [Post]()
                if NCMBUser.current() == nil {
                    // ログアウト成功
                    let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                    let rootViewController = storyboard.instantiateViewController(withIdentifier: "SignInController")
                    UIApplication.shared.keyWindow?.rootViewController = rootViewController
                    
                    // ログイン状態の保持
                    let ud = UserDefaults.standard
                    ud.set(false, forKey: "isLogin")
                    ud.synchronize()
                }else{
                    for postObject in result as! [NCMBObject] {
                        // ユーザー情報をUserクラスにセット
                        let user = postObject.object(forKey: "user") as! NCMBUser
                        
                        
                        // 退会済みユーザーの投稿を避けるため、activeがfalse以外のモノだけを表示
                        if user.object(forKey: "active") as? Bool != false {
                            
                            // 投稿したユーザーの情報をUserモデルにまとめる
                            let userModel = User(objectId: user.objectId, userName: user.userName)
                            userModel.displayName = user.object(forKey: "displayName") as? String
                            
                            // 投稿の情報を取得
                            let imageUrl = postObject.object(forKey: "imageUrl") as! String
                            let text = postObject.object(forKey: "text") as! String
                            
                            if postObject.object(forKey: "CommentsCount") != nil{
                                self.commentOfCount = postObject.object(forKey: "CommentsCount") as! Int
                            }else{
                                self.commentOfCount = 0
                            }
                            if postObject.object(forKey: "userCheck") != nil{
                                self.userCheck = postObject.object(forKey: "userCheck") as! String
                            }else{
                                self.userCheck = "匿名"
                            }
                            if postObject.object(forKey: "comment") != nil {
                                self.postComment = postObject.object(forKey: "comment") as! String
                            }else{
                                self.postComment = ""
                            }
                            if postObject.object(forKey: "postUrl") != nil{
                                self.postUrl = postObject.object(forKey: "postUrl") as! String
                            }else{
                                self.postUrl = ""
                            }
                            if postObject == result?[0] as! NCMBObject {
                                self.rankCheck = 1
                            }else if postObject == result?[1] as! NCMBObject{
                                self.rankCheck = 1
                            }else if postObject == result?[2] as! NCMBObject{
                                self.rankCheck = 1
                            }else{
                                self.rankCheck = 0
                            }
                            // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
                            let post = Post(objectId: postObject.objectId, user: userModel, imageUrl: imageUrl,postUrl: self.postUrl, text: text,postComment:self.postComment,userCheck:self.userCheck,rankCheck:self.rankCheck,commentsCount:self.commentOfCount, createDate: postObject.createDate)
                            self.currentUser()
                            // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
                            let likeUsers = postObject.object(forKey: "likeUser") as? [String]
                            if likeUsers?.contains(NCMBUser.current().objectId) == true {
                                post.isLiked = true
                            } else {
                                post.isLiked = false
                            }
                            
                            // いいねの件数
                            if let likes = likeUsers {
                                post.likeCount = likes.count
                            }
                            
                            
                            // 配列に加える
                            self.posts.append(post)
                        }
                    }
                }
                // 投稿のデータが揃ったらTableViewをリロード
                self.timelineTableView.reloadData()
                
            }
        })
    }
    
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTimeline(refreshControl:)), for: .valueChanged)
        timelineTableView.addSubview(refreshControl)
    }
    
    @objc func reloadTimeline(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        //self.loadFollowingUsers()
        // 更新が早すぎるので2秒遅延させる
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            refreshControl.endRefreshing()
        }
    }
    
    
    @IBAction func addTopic(_ sender: Any) {
        self.performSegue(withIdentifier: "addTopic", sender: nil)
    }
    
}
