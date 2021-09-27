//
//  ViewController.swift
//  YQRefresh
//
//  Created by 王叶庆 on 2017/2/10.
//  Copyright © 2017年 王叶庆. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var count: Int = 5
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "\(UITableViewCell.self)")
        self.tableView.addObserver(self, forKeyPath: "contentInset", options: .new, context: nil)
       
        let header = YQRefreshHeader{[weak self] () in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                self?.tableView.yq.header?.endRefreshing()
            }
        }
        
        if #available(iOS 11.0, *) {
            let yOffset = UIApplication.shared.statusBarFrame.height + (self.navigationController?.navigationBar.frame.height ?? 0)
            self.tableView.contentInsetAdjustmentBehavior = .never
            header.yOffset = yOffset
            self.tableView.contentInset = UIEdgeInsets(top: yOffset, left: 0, bottom: 0, right: 0)
        } else {
            // Fallback on earlier versions
        }
        self.tableView.yq.header = header
        if let actor = self.tableView.yq.header?.actor as? PacmanActor {
            actor.color = UIColor.blue
        }

//        self.tableView.yq.footer = YQRefreshFooter{[weak self] () in
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4) {
//                self?.tableView.yq.footer?.endRefreshing()
//            }
//        }
        self.tableView.yq.footer = YQAutoRefreshFooter { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                let count = Int.random(in: 0 ... 4)
                guard count > 0 else {
                    self?.tableView.yq.footer?.noMore()
                    return
                }
                self?.count += count
                self?.tableView.reloadData()
                self?.tableView.yq.footer?.endRefreshing()
            }
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)")!
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print(change?[NSKeyValueChangeKey.newKey])
    }
}

