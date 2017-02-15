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
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "\(UITableViewCell.self)")
        self.tableView.contentInset = UIEdgeInsets(top: 80, left: 0, bottom: 90, right: 0)
        self.tableView.yq.header = YQRefreshHeader{[weak self] () in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4) {
                self?.tableView.yq.header?.endRefreshing()
            }
        }
        self.tableView.yq.footer = YQRefreshFooter{[weak self] () in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4) {
                self?.tableView.yq.footer?.endRefreshing()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)")!
        return cell
    }
}

