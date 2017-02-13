//
//  ViewController.swift
//  YQRefresh
//
//  Created by 王叶庆 on 2017/2/10.
//  Copyright © 2017年 王叶庆. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.contentInset = UIEdgeInsets(top: 80, left: 0, bottom: 0, right: 0)
        self.tableView.yq.header = YQRefreshHeader{[weak self] () in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4) {
                self?.tableView.yq.header?.endRefreshing()
            }
        }
        self.tableView.yq.header?.beginRefreshing()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4) {
            self.tableView.yq.header?.endRefreshing()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

