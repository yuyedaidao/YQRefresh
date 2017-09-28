//
//  YQRefreshFooter.swift
//  YQRefresh
//
//  Created by 王叶庆 on 2017/2/13.
//  Copyright © 2017年 王叶庆. All rights reserved.
//

import UIKit

public class YQRefreshFooter: UIView, YQRefresher {

    public var actor: YQRefreshActor? {
        didSet {
            guard let a = actor as? UIView else {
                return
            }
            if let old = oldValue as? UIView {
                old.removeFromSuperview()
            }
            addSubview(a)
        }
    }
    public var action: YQRefreshAction?
    public var refresherHeight: CGFloat = YQRefresherHeight
    public var originalInset: UIEdgeInsets = UIEdgeInsets.zero
    public var pullingPercentOffset: CGFloat = YQRefresherHeight / 2
    var topSpaceConstraint: NSLayoutConstraint!
    var headerRefreshObserver: NSObjectProtocol?
    
    public var state: YQRefreshState = .default {
        didSet {
            guard oldValue != state else {
                return
            }
            switch state {
            case .default:
                resetScrollView()
            case .refreshing:
                if let scroll = scrollView {
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
                resetScrollView()
            default:
                break
            }
            actor?.state = state
        }
    }
    weak public var scrollView: UIScrollView? {
        didSet {
            if let scroll = scrollView {
                scroll.addObserver(self, forKeyPath: YQKVOContentOffset, options: .new, context: UnsafeMutableRawPointer(&YQKVOContentOffset))
                scroll.addObserver(self, forKeyPath: YQKVOContentSize, options: .new, context: UnsafeMutableRawPointer(&YQKVOContentSize))
            }
        }
    }
    
    public var pullingPercent: Double = 0 {
        didSet {
            actor?.pullingPrecent = pullingPercent
        }
    }
    
    public init (_ actor: YQRefreshActor? = nil, _ action: @escaping YQRefreshAction) {
        self.actor = actor
        self.action = action
        if actor == nil {
            let actor = FooterActor(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 100, height: refresherHeight)))
            self.actor = actor
        }
        super.init(frame: CGRect.zero)
        if let actor = self.actor as? UIView {
            addSubview(actor)
            
        }
        dealHeaderRefreshNotification()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let observer = headerRefreshObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard let actor = actor as? UIView else {
            return
        }
        actor.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    
    override public func willMove(toSuperview newSuperview: UIView?) {
        func removeObservers(on view: UIView?) {
            view?.removeObserver(self, forKeyPath: YQKVOContentOffset, context: UnsafeMutableRawPointer(&YQKVOContentOffset))
            view?.removeObserver(self, forKeyPath: YQKVOContentSize, context: UnsafeMutableRawPointer(&YQKVOContentSize))
        }
        if let scroll = newSuperview as? UIScrollView {
            scrollView = scroll
        } else {
            removeObservers(on: superview)
        }
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let scroll = scrollView {
            if context == UnsafeMutableRawPointer(&YQKVOContentOffset) {
                guard state != .refreshing, state != .noMore else {
                    return
                }
                let visibleMaxY = scroll.contentOffset.y + scroll.bounds.height
                let contentBottom = scroll.contentSize.height + originalInset.bottom
                guard visibleMaxY > contentBottom else {
                    return
                }
                let percent = (visibleMaxY - contentBottom - pullingPercentOffset) / (refresherHeight - pullingPercentOffset)
                pullingPercent = max(min(Double(percent), 1), 0)
                if scroll.isDragging {
                    let triggerOffset = contentBottom + refresherHeight
                    if state == .default && visibleMaxY >= triggerOffset{
                        state = .pulling
                    } else if state == .pulling && visibleMaxY < triggerOffset{
                        state = .default
                    }
                } else {
                    if state == .pulling {
                        beginRefreshing()
                    }
                }
            } else if context == UnsafeMutableRawPointer(&YQKVOContentSize){
                topSpaceConstraint.constant = scroll.contentSize.height + originalInset.bottom
            }
        }
    }
    
    private func resetScrollView() {
        if let scroll = scrollView, scroll.contentInset.bottom != originalInset.bottom {
            UIView.animate(withDuration: YQRefresherAnimationDuration, animations: {
                let bottom = self.originalInset.bottom
                scroll.contentInset.bottom = bottom
                scroll.contentOffset.y = scroll.contentSize.height - scroll.bounds.height + bottom
            })
        }
    }
    
    private func dealHeaderRefreshNotification() {
        headerRefreshObserver = NotificationCenter.default.addObserver(forName: Notification.Name(YQNotificatonHeaderRefresh), object: nil, queue: nil) { (notification) in
            if self.state == .noMore {
                self.state = .default
            }
        }
        
    }
    
    //public
    
    public func beginRefreshing() {
        pullingPercent = 1
        state = .refreshing
    }
    
    public func endRefreshing() {
        state = .default
        pullingPercent = 0
    }
    
    func hasNoMore() {
        state = .noMore
    }
}
