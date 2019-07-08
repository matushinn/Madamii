//
//  timelineViewController.swift
//  Login
//
//  Created by 大江祥太郎 on 2019/07/07.
//  Copyright © 2019 shotaro. All rights reserved.
//

import UIKit

class timelineViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    

    @IBOutlet weak var timelineTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        timelineTableView.delegate = self
        timelineTableView.dataSource = self
        
        let nib = UINib(nibName: "TimeLineTableViewCell", bundle: Bundle.main)
        timelineTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        timelineTableView.tableFooterView = UIView()
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TimeLineTableViewCell
        cell.userNameLabel.text = "サンプル"
        
        return cell
        
    }
    

    

}
