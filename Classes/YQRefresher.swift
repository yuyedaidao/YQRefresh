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

var YQKVOContentOffset = "contentOffset"
var YQKVOContentSize = "contentSize"

let YQRefresherHeight: CGFloat = 60.0
let YQRefresherAnimationDuration = 0.25

let YQNotificatonHeaderRefresh = "YQNotificatonHeaderRefresh"

public typealias YQRefreshAction = ()->Void

public protocol YQRefresher {
    var state: YQRefreshState {get set}
    var scrollView: UIScrollView? {get set}
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

public protocol YQRefreshActor where Self: UIView {
    var state: YQRefreshState {get set}
    var pullingPrecent: Double {get set}
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
    
    public var header: YQRefresher? {
        get {
            return base.viewWithTag(headerTag) as? YQRefresher
        }
        
        set {
            if let refresher = base.viewWithTag(headerTag) {
                refresher.removeFromSuperview()
            }
            if let refresher =  newValue as? YQRefreshHeader {
                refresher.tag = headerTag
                refresher.translatesAutoresizingMaskIntoConstraints = false
                refresher.originalInset = base.contentInset
                base.addSubview(refresher)
                refresher.addConstraint(NSLayoutConstraint(item: refresher, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: YQRefresherHeight))
                base.addConstraint(NSLayoutConstraint(item: refresher, attribute: .width, relatedBy: .equal, toItem: base, attribute: .width, multiplier: 1, constant: 0))
                base.addConstraint(NSLayoutConstraint(item: base, attribute: .leading, relatedBy: .equal, toItem: refresher, attribute: .leading, multiplier: 1, constant: 0))
                base.addConstraint(NSLayoutConstraint(item: refresher, attribute: .bottom, relatedBy: .equal, toItem: base, attribute: .top, multiplier: 1, constant: -refresher.originalInset.top))
                base.superview?.setNeedsLayout()
                base.superview?.layoutIfNeeded()
            }
        }
    }
    
    public var footer: YQRefresher? {
        get {
            return base.viewWithTag(footerTag) as? YQRefresher
        }
        set {
            if let refresher = base.viewWithTag(footerTag) {
                refresher.removeFromSuperview()
            }
            if let refresher = newValue as? YQRefreshFooter {
                refresher.tag = footerTag
                refresher.originalInset = base.contentInset
                refresher.translatesAutoresizingMaskIntoConstraints = false
                base.addSubview(refresher)
                refresher.addConstraint(NSLayoutConstraint(item: refresher, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: YQRefresherHeight))
                base.addConstraint(NSLayoutConstraint(item: refresher, attribute: .width, relatedBy: .equal, toItem: base, attribute: .width, multiplier: 1, constant: 0))
                base.addConstraint(NSLayoutConstraint(item: base, attribute: .leading, relatedBy: .equal, toItem: refresher, attribute: .leading, multiplier: 1, constant: 0))
                refresher.topSpaceConstraint = NSLayoutConstraint(item: refresher, attribute: .top, relatedBy: .equal, toItem: base, attribute: .top, multiplier: 1, constant: 10000)
                base.addConstraint(refresher.topSpaceConstraint)
            }

        }
    }
}

public extension UIScrollView {
   
    var yq:YQRefreshContainer {
        get {
            return YQRefreshContainer(self)
        }
        set {
            //nothing
        }
    }
}

