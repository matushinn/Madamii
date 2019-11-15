
//
//  ScrollViewController.swift
//  Login
//
//  Created by 大江祥太郎 on 2019/10/13.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit
import Lottie

class ScrollViewController: UIViewController {

    var onboardStringArray = ["まだ話し足りない？ それなら、マダミィで語り尽くそう","マダミィは50代女性の「頭の中」を映す鏡","そしてマダミィがあなたの第3の居場所になる"]
    
    var animationArray = ["onboard1","onboard2","onboard3"]
    
    @IBOutlet weak var skipLabel: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        scrollView.isPagingEnabled = true
        //ナビゲーションアイテムのタイトルに画像を設定する。
        self.navigationItem.titleView = UIImageView(image:UIImage(named:"madamii_head"))
        setUpScroll()
        
        //animation
        for i in 0...2{
            let animationView = AnimationView()
            let animation = Animation.named(animationArray[i])
            animationView.frame = CGRect(x: CGFloat(i) * self.view.frame.width, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            
            animationView.animation = animation
            animationView.contentMode = .scaleAspectFit
            animationView.loopMode = .loop
            animationView.play()
            scrollView.addSubview(animationView)
            
            
        }
    }
    func setUpScroll(){
        //スクロールビューを貼り付ける
        
        //3つ分
        scrollView.contentSize = CGSize(width: view.frame.size.width * 3, height: view.frame.size.height)
        
        
        for i in 0...2 {
            let onboardLabel = UILabel(frame: CGRect(x: CGFloat(i)*self.view.frame.size.width, y: self.view.frame.height/3, width: scrollView.frame.size.width, height: scrollView.frame.size.height))
            
            onboardLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
            onboardLabel.textAlignment = .center
            onboardLabel.text = onboardStringArray[i]
            scrollView.addSubview(onboardLabel)
            
            
            
        }
    }

    

}
