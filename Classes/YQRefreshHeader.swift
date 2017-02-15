//
//  YQRefreshHeader.swift
//  YQRefresh
//
//  Created by 王叶庆 on 2017/2/10.
//  Copyright © 2017年 王叶庆. All rights reserved.
//

import UIKit

open class YQRefreshHeader: UIView, YQRefresher{
    
    var actor: YQRefreshActor?
    var action: YQRefreshAction?
    var refresherHeight: CGFloat = YQRefresherHeight
    var originalInset: UIEdgeInsets = UIEdgeInsets.zero
    var pullingPercentOffset: CGFloat = YQRefresherHeight / 2
    
    var state: YQRefreshState = .default {
        didSet {
            switch state {
            case .default:
                if self.scrollView?.contentInset.top != self.originalInset.top {
                    UIView.animate(withDuration: YQRefresherAnimationDuration, animations: {
                        let top = self.originalInset.top
                        self.scrollView?.contentInset.top = top
                        self.scrollView?.contentOffset.y = -top
                    })
                }
            case .refreshing:
                UIView.animate(withDuration: YQRefresherAnimationDuration, animations: {
                    let top = self.refresherHeight + self.originalInset.top
                    self.scrollView?.contentInset.top = top
                    self.scrollView?.contentOffset.y = -top
                }, completion: { (isFinished) in
                    if let action = self.action {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: YQNotificatonHeaderRefresh), object: nil)
                        action()
                    }
                })
                
            default:
                break
            }
            self.actor?.setState(state)
        }
    }
    weak var scrollView: UIScrollView? {
        didSet {
            if let scroll = scrollView {
                scroll.addObserver(self, forKeyPath: YQKVOContentOffset, options: .new, context: UnsafeMutableRawPointer(&YQKVOContentOffset))
            }
        }
    }
    var pullingPercent: Double = 0 {
        didSet {
            self.actor?.setPullingPrecent(pullingPercent)
        }
    }

    
    func beginRefreshing() {
        self.pullingPercent = 1
        self.state = .refreshing
    }
    
    func endRefreshing() {
        self.state = .default
        self.pullingPercent = 0
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let scroll = self.scrollView {
            guard state != .refreshing else {
                return
            }
            let offsetY = scroll.contentOffset.y
            guard offsetY < -self.originalInset.top else {
                return
            }
            let triggerOffset = -self.originalInset.top - self.refresherHeight
            let percent = (-self.originalInset.top - offsetY - self.pullingPercentOffset) / (self.refresherHeight - self.pullingPercentOffset)
            self.pullingPercent = max(min(Double(percent), 1), 0)
            if scroll.isDragging {
                if self.state == .default && offsetY <= triggerOffset{
                    self.state = .pulling
                } else if self.state == .pulling && offsetY > triggerOffset{
                    self.state = .default
                }
            } else {
                if self.state == .pulling {
                    self.beginRefreshing()
                }
            }
        }
    }

    init (_ actor: YQRefreshActor? = nil, _ action: @escaping YQRefreshAction) {
        self.actor = actor
        self.action = action
        super.init(frame: CGRect.zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        func removeObservers(on view: UIView?) {
            view?.removeObserver(self, forKeyPath: YQKVOContentOffset, context: UnsafeMutableRawPointer(&YQKVOContentOffset))
        }
        if let scroll = newSuperview as? UIScrollView {
            self.scrollView = scroll
        } else {
            removeObservers(on: self.superview)
        }
    }
}
