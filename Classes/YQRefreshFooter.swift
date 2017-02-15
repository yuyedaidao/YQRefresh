//
//  YQRefreshFooter.swift
//  YQRefresh
//
//  Created by 王叶庆 on 2017/2/13.
//  Copyright © 2017年 王叶庆. All rights reserved.
//

import UIKit

public class YQRefreshFooter: UIView, YQRefresher {

    var actor: YQRefreshActor?
    var action: YQRefreshAction?
    var refresherHeight: CGFloat = YQRefresherHeight
    var originalInset: UIEdgeInsets = UIEdgeInsets.zero
    var pullingPercentOffset: CGFloat = YQRefresherHeight / 2
    var topSpaceConstraint: NSLayoutConstraint!
    var headerRefreshObserver: NSObjectProtocol?
    
    var state: YQRefreshState = .default {
        didSet {
            switch state {
            case .default:
                self.resetScrollView()
            case .refreshing:
                if let scroll = self.scrollView {
                    UIView.animate(withDuration: YQRefresherAnimationDuration, animations: {
                        let bottom = self.originalInset.bottom + self.refresherHeight
                        scroll.contentInset.bottom = bottom
                        scroll.contentOffset.y = scroll.contentSize.height - scroll.bounds.height + bottom
                    }, completion: { (isFinished) in
                        if let action = self.action {
                            action()
                        }
                    })
                }
            case .noMore:
                self.resetScrollView()
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
                scroll.addObserver(self, forKeyPath: YQKVOContentSize, options: .new, context: UnsafeMutableRawPointer(&YQKVOContentSize))
            }
        }
    }
    
    var pullingPercent: Double = 0 {
        didSet {
            self.actor?.setPullingPrecent(pullingPercent)
        }
    }
    
    init (_ actor: YQRefreshActor? = nil, _ action: @escaping YQRefreshAction) {
        self.actor = actor
        self.action = action
        super.init(frame: CGRect.zero)
        self.dealHeaderRefreshNotification()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let observer = self.headerRefreshObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    override public func willMove(toSuperview newSuperview: UIView?) {
        func removeObservers(on view: UIView?) {
            view?.removeObserver(self, forKeyPath: YQKVOContentOffset, context: UnsafeMutableRawPointer(&YQKVOContentOffset))
            view?.removeObserver(self, forKeyPath: YQKVOContentSize, context: UnsafeMutableRawPointer(&YQKVOContentSize))
        }
        if let scroll = newSuperview as? UIScrollView {
            self.scrollView = scroll
        } else {
            removeObservers(on: self.superview)
        }
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let scroll = self.scrollView {
            if context == UnsafeMutableRawPointer(&YQKVOContentOffset) {
                guard state != .refreshing, state != .noMore else {
                    return
                }
                let visibleMaxY = scroll.contentOffset.y + scroll.bounds.height
                let contentBottom = scroll.contentSize.height + self.originalInset.bottom
                guard visibleMaxY > contentBottom else {
                    return
                }
                let percent = (visibleMaxY - contentBottom - self.pullingPercentOffset) / (self.refresherHeight - self.pullingPercentOffset)
                self.pullingPercent = max(min(Double(percent), 1), 0)
                if scroll.isDragging {
                    let triggerOffset = contentBottom + self.refresherHeight
                    if self.state == .default && visibleMaxY >= triggerOffset{
                        self.state = .pulling
                    } else if self.state == .pulling && visibleMaxY < triggerOffset{
                        self.state = .default
                    }
                } else {
                    if self.state == .pulling {
                        self.beginRefreshing()
                    }
                }
            } else if context == UnsafeMutableRawPointer(&YQKVOContentSize){
                topSpaceConstraint.constant = scroll.contentSize.height + self.originalInset.bottom
            }
        }
    }
    
    private func resetScrollView() {
        if let scroll = self.scrollView, scroll.contentInset.bottom != self.originalInset.bottom {
            UIView.animate(withDuration: YQRefresherAnimationDuration, animations: {
                let bottom = self.originalInset.bottom
                scroll.contentInset.bottom = bottom
                scroll.contentOffset.y = scroll.contentSize.height - scroll.bounds.height + bottom
            })
        }
    }
    
    private func dealHeaderRefreshNotification() {
        self.headerRefreshObserver = NotificationCenter.default.addObserver(forName: Notification.Name(YQNotificatonHeaderRefresh), object: nil, queue: nil) { (notification) in
            if self.state == .noMore {
                self.state = .default
            }
        }
        
    }
    
    //public
    
    func beginRefreshing() {
        self.pullingPercent = 1
        self.state = .refreshing
    }
    
    func endRefreshing() {
        self.state = .default
        self.pullingPercent = 0
    }
    
    func hasNoMore() {
        self.state = .noMore
    }
}
