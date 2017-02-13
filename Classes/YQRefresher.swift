//
//  YQRefreshable.swift
//  YQRefresh
//
//  Created by 王叶庆 on 2017/2/10.
//  Copyright © 2017年 王叶庆. All rights reserved.
//

import UIKit

public enum YQRefreshState {
    case `default`
    case pulling
    case refreshing
    case noMore
}

let YQRefresherHeight: CGFloat = 60.0
let YQRefresherAnimationDuration = 0.25
typealias YQRefreshAction = (Void)->Void

protocol YQRefresher {
    var state: YQRefreshState {get set}
    weak var scrollView: UIScrollView? {get set}
    var pullingPercent: Double {get set}
    var refresherHeight: CGFloat {get}
    /// 如果以开始拖动为百分比计算开始可能会看不到完整动画，所以添加一个偏移量，默认是Refresher高度的一半
    var pullingPercentOffset: CGFloat {get set}
    var actor: YQRefreshActor? {get set}
    var action: YQRefreshAction? {get set}
    var originalInset: UIEdgeInsets {get set}
    func beginRefreshing()
    func endRefreshing()
}

public protocol YQRefreshActor {
    func setState(_ state: YQRefreshState)
    func setPullingPrecent(_ present: Double)
}

protocol YQRefreshable {
    var header: YQRefresher? {get set}
    var footer: YQRefresher? {get set}
}

public struct YQRefreshContainer: YQRefreshable {
    let base:UIScrollView
    let headerTag = 1008601
    let footerTag = 1008602
    init(_ base: UIScrollView) {
        self.base = base
    }
    
    var header: YQRefresher? {
        get {
            return self.base.viewWithTag(headerTag) as? YQRefresher
        }
        
        set {
            if let refresher = self.base.viewWithTag(headerTag) {
                refresher.removeFromSuperview()
            }
            if let refresher =  newValue as? YQRefreshHeader {
                refresher.tag = headerTag
                refresher.backgroundColor = UIColor.blue
                refresher.translatesAutoresizingMaskIntoConstraints = false
                refresher.originalInset = self.base.contentInset
                self.base.addSubview(refresher)
                refresher.addConstraint(NSLayoutConstraint(item: refresher, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: YQRefresherHeight))
                self.base.addConstraint(NSLayoutConstraint(item: refresher, attribute: .width, relatedBy: .equal, toItem: self.base, attribute: .width, multiplier: 1, constant: 0))
                self.base.addConstraint(NSLayoutConstraint(item: self.base, attribute: .leading, relatedBy: .equal, toItem: refresher, attribute: .leading, multiplier: 1, constant: 0))
                self.base.addConstraint(NSLayoutConstraint(item: refresher, attribute: .bottom, relatedBy: .equal, toItem: self.base, attribute: .top, multiplier: 1, constant: -refresher.originalInset.top))
                refresher.scrollView = self.base
            }
        }
    }
    
    var footer: YQRefresher? {
        get {
            return self.base.viewWithTag(footerTag) as? YQRefresher
        }
        
        set {
            
        }
    }
}

extension UIScrollView {
   
    var yq:YQRefreshContainer {
        get {
            return YQRefreshContainer(self)
        }
        set {
            //nothing
        }
    }
}

