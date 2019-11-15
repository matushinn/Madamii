//
//  SearchViewController.swift
//  Login
//
//  Created by 大江祥太郎 on 2019/07/17.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD
import Kingfisher

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, TimeLineTableViewCellDelegate {
    
    
    var selectedPost: Post?
    
    var posts = [Post]()
    
    var comments = [Comment]()
    
    var followings = [NCMBUser]()
    
    var commentOfCount = 0
    
    var flag = 0
    
    var userCheck = ""
    
    var postComment = ""
    
    var postUrl = ""
    
    var searchBar: UISearchBar!
    
    @IBOutlet var searchPostTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSearchBar()
        
        searchPostTableView.dataSource = self
        searchPostTableView.delegate = self
        
        // カスタムセルの登録
        let nib = UINib(nibName: "TimeLineTableViewCell", bundle: Bundle.main)
        searchPostTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        // 余計な線を消す
        searchPostTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadPosts(searchText: nil)
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
        if segue.identifier == "toComments" {
            let commentViewController = segue.destination as! CommentViewController
            commentViewController.postId = selectedPost?.objectId
            commentViewController.selectedPost = selectedPost
            
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
                        self.loadPosts(searchText: nil)
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
                            self.loadPosts(searchText: nil)
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
                            self.loadPosts(searchText: nil)
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
    
    func setSearchBar() {
        // NavigationBarにSearchBarをセット
        if let navigationBarFrame = self.navigationController?.navigationBar.bounds {
            let searchBar: UISearchBar = UISearchBar(frame: navigationBarFrame)
            searchBar.delegate = self
            searchBar.placeholder = "トピックを検索"
            searchBar.autocapitalizationType = UITextAutocapitalizationType.none
            navigationItem.titleView = searchBar
            navigationItem.titleView?.frame = searchBar.frame
            self.searchBar = searchBar
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        loadPosts(searchText: nil)
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadPosts(searchText: nil)
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        loadPosts(searchText: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadPosts(searchText: searchBar.text)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TimeLineTableViewCell
        
        cell.delegate = self
        cell.tag = indexPath.row
        
        let user = posts[indexPath.row].user
        
        cell.commentLabel.text = posts[indexPath.row].text
        let imageUrl = posts[indexPath.row].imageUrl
        cell.topicImageView.kf.setImage(with: URL(string: imageUrl), placeholder: UIImage(named: "placeholder.jpg"))
        
        // Likeによってハートの表示を変える
        if posts[indexPath.row].isLiked == true {
            cell.likeButton.setImage(UIImage(named: "heart-fill"), for: .normal)
        } else {
            cell.likeButton.setImage(UIImage(named: "heart-outline"), for: .normal)
        }
        //コメントランク
        cell.commentRankLabel.alpha = 0
        
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
    
    
    
    
    func loadPosts(searchText: String?) {
        let query = NCMBQuery(className: "Post")
        
        query?.order(byDescending: "createDate")
        
       
        // 検索ワードがある場合
        if let text = searchText {
            query?.whereKey("text", equalTo: text)
            // 投稿したユーザーの情報も同時取得
            query?.includeKey("user")
            
            currentUser()            
            
            // 新着ユーザー50人だけ拾う
            query?.limit = 50
            
            
            query?.findObjectsInBackground({ (result, error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                } else {
                    for postObject in result as! [NCMBObject] {
                        // ユーザー情報をUserクラスにセット
                        let user = postObject.object(forKey: "user") as! NCMBUser
                        // 退会済みユーザーの投稿を避けるため、activeがfalse以外のモノだけを表示
                        if user.object(forKey: "active") as? Bool != false {
                            // 投稿したユーザーの情報をUserモデルにまとめる
                            let userModel = User(objectId: user.objectId, userName: user.userName)
                            
                            //let userModel = User(objectId: user.objectId, userName: user.userName)
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
                            
                            let post = Post(objectId: postObject.objectId, user: userModel, imageUrl: imageUrl,postUrl: self.postUrl, text: text,postComment:self.postComment,userCheck:self.userCheck,rankCheck:0,commentsCount:self.commentOfCount, createDate: postObject.createDate)
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
                self.searchPostTableView.reloadData()
            })
        }else{
            posts = []
            // 投稿のデータが揃ったらTableViewをリロード
            self.searchPostTableView.reloadData()
        }
        
        
    }
}


    
    
   
    

