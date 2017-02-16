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
let YQHeaderTag = 1008601
let YQFooterTag = 1008602
let YQNotificatonHeaderRefresh = "YQNotificatonHeaderRefresh"

public typealias YQRefreshAction = (Void)->Void

public protocol YQRefresher{
    var state: YQRefreshState {get set}
    weak var scrollView: UIScrollView? {get set}
    var pullingPercent: Double {get set}
    var refresherHeight: CGFloat {get}
    /// 如果以开始拖动为百分比计算开始可能会看不到完整动画，所以添加一个偏移量，默认是Refresher高度的一半
    var pullingPercentOffset: CGFloat {get set}
    var actor: YQRefreshActor? {get set}
    var action: YQRefreshAction? {get set}
    var originalInset: UIEdgeInsets {get set}
    func addInto(_ view: UIScrollView)
    func beginRefreshing()
    func endRefreshing()
}

public protocol YQRefreshActor {
    func setState(_ state: YQRefreshState)
    func setPullingPrecent(_ present: Double)
}

//public protocol YQRefreshFooterActor: YQRefreshActor {
//    func hasNoMore()
//}
public protocol YQRefresherHeader: YQRefresher {}

public protocol YQRefresherFooter: YQRefresher {
    func hasNoMore()
}

protocol YQRefreshable {
    var header: YQRefresherHeader? {get set}
    var footer: YQRefresherFooter? {get set}
}

public struct YQRefreshContainer: YQRefreshable {
    let base:UIScrollView
    
    init(_ base: UIScrollView) {
        self.base = base
    }
    
    var header: YQRefresherHeader? {
        get {
            return self.base.viewWithTag(YQHeaderTag) as? YQRefresherHeader
        }
        
        set {
            if let refresher = self.base.viewWithTag(YQHeaderTag) {
                refresher.removeFromSuperview()
            }
            if let refresher = newValue {
                refresher.addInto(self.base)
            }
        }
    }
    
    var footer: YQRefresherFooter? {
        get {
            return self.base.viewWithTag(YQFooterTag) as? YQRefresherFooter
        }
        
        set {
            if let refresher = self.base.viewWithTag(YQFooterTag) {
                refresher.removeFromSuperview()
            }
            if let refresher = newValue {
                refresher.addInto(self.base)
            }

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

