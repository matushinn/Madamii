


//
//  ShowUserViewController.swift
//  Login
//
//  Created by 大江祥太郎 on 2019/10/15.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit
import NCMB
import Kingfisher
import SVProgressHUD

class ShowUserViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, TimeLineTableViewCellDelegate {
    var selectedUser: NCMBUser!
    
    var selectedPost: Post?

    
    var followings = [NCMBUser]()
    
    var seg_change = 0
    
    var commentOfCount = 0
    var followingInfo: NCMBObject?
    var userCheck = ""
    
    var postComment = ""
    
    var posts = [Post]()
    
    var postUrl = ""
    

    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var userDisplayNameLabel: UILabel!
    
    @IBOutlet weak var timelineSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var userIntroductionTextView: UITextView!
    
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var postCountLabel: UILabel!
    @IBOutlet weak var userPageTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        
        // ユーザー基礎情報の読み込み
        userDisplayNameLabel.text = selectedUser.object(forKey: "displayName") as? String
        userIntroductionTextView.text = selectedUser.object(forKey: "introduction") as? String
        self.navigationItem.title = selectedUser.userName
        
        // プロフィール画像の読み込み
        let file = NCMBFile.file(withName: selectedUser.objectId, data: nil) as! NCMBFile
        file.getDataInBackground { (data, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                if data != nil {
                    let image = UIImage(data: data!)
                    self.userImageView.image = image
                }
            }
        }
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
                        self.loadPosts()
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
                            self.loadPosts()
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
                            self.loadPosts()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TimeLineTableViewCell
        
        cell.delegate = self
        cell.tag = indexPath.row
        
        cell.commentLabel.text = self.posts[indexPath.row].text
        
        cell.commentRankLabel.alpha = 0
        let photoImagePath = posts[indexPath.row].imageUrl
        cell.topicImageView!.kf.setImage(with: URL(string: photoImagePath),placeholder: UIImage(named: "placeholder.jpg"))
        
        // Likeによってハートの表示を変える
        if posts[indexPath.row].isLiked == true {
            cell.likeButton.setImage(UIImage(named: "heart-fill"), for: .normal)
        } else {
            cell.likeButton.setImage(UIImage(named: "heart-outline"), for: .normal)
        }
        
        // Likeの数
        //cell.likeCountLabel.text = "\(posts[indexPath.row].likeCount)件"
        
        // タイムスタンプ(投稿日時) (※フォーマットのためにSwiftDateライブラリをimport)
        cell.timeStampLabel.text = posts[indexPath.row].createDate.toString()
        
        cell.commentCountLabel.text = "\(posts[indexPath.row].commentsCount)件"
        
        return cell
    }
    func loadPosts() {
        let query = NCMBQuery(className: "Post")
        // 降順
        query?.order(byDescending: "createDate")
        
        if self.seg_change == 0 {
            query?.includeKey("user")
            query?.whereKey("user", equalTo: NCMBUser.current())
        }else if self.seg_change == 1{
            query?.includeKey("user")
        }
        
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                self.posts = [Post]()
                
                for postObject in result as! [NCMBObject] {
                    //投稿タイムライン
                    //ユーザー情報をUserクラスにセット
                    let user = postObject.object(forKey: "user") as! NCMBUser
                    let userModel = User(objectId: user.objectId, userName: user.userName)
                    userModel.displayName = user.object(forKey: "displayName") as? String
                    
                    // 投稿の情報を取得
                    let imageUrl = postObject.object(forKey: "imageUrl") as! String
                    let text = postObject.object(forKey: "text") as!  String
                    
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
                    
                    
                    
                    if postObject.object(forKey: "comment") != nil{
                        self.postComment = postObject.object(forKey: "comment") as! String
                    }else{
                        self.postComment = ""
                    }
                    
                    if postObject.object(forKey: "postUrl") != nil{
                        self.postUrl = postObject.object(forKey: "postUrl") as! String
                    }else{
                        self.postUrl = ""
                    }
                    
                    // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
                    let post = Post(objectId: postObject.objectId, user: userModel, imageUrl: imageUrl,postUrl: self.postUrl, text: text,postComment:self.postComment,userCheck:self.userCheck,rankCheck:0,commentsCount:self.commentOfCount, createDate: postObject.createDate)
                    
                    // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
                    let likeUser = postObject.object(forKey: "likeUser") as? [String]
                    if likeUser?.contains(NCMBUser.current().objectId) == true {
                        post.isLiked = true
                        // 配列に加える
                        self.posts.append(post)
                    } else {
                        post.isLiked = false
                        if self.seg_change == 0{
                            // 配列に加える
                            self.posts.append(post)
                           
                        }
                    }
                    
                    
                }
                
                self.userPageTableView.reloadData()
                if self.seg_change == 1{
                    self.postsLabel.text = "いいね数"
                }else if self.seg_change == 0{
                    self.postsLabel.text = "投稿数"
                }
                // post数を表示
                self.postCountLabel.text = String(self.posts.count)
            }
        })
    }
    @IBAction func `switch`(_ sender: UISegmentedControl) {
        let selectedIndex = timelineSegmentedControl.selectedSegmentIndex
        //選択されたインデックスの文字列を取得してラベルに設定
        switch selectedIndex {
        case 0:
            self.seg_change = 0
        case 1:
            self.seg_change = 1
        default:
            break
        }
        loadPosts()
       
    }
   
}
