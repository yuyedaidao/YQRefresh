//
//  YQAutoRefreshFooter.swift
//  YQRefresh
//
//  Created by 王叶庆 on 2021/9/18.
//  Copyright © 2021 王叶庆. All rights reserved.
//

import UIKit

public class YQAutoRefreshFooter: UIView, FooterRefresher {
    public var actor: YQRefreshActor? {
        didSet {
            guard let actor = actor else {
                return
            }
            if let old = oldValue {
                old.removeFromSuperview()
            }
            addSubview(actor)
        }
    }

    public var action: YQRefreshAction?
    public var refresherHeight: CGFloat = YQRefresherHeight
    public var originalInset = UIEdgeInsets.zero
    public var pullingPercentOffset: CGFloat = YQRefresherHeight / 2
    public var yOffset: CGFloat = 0
    public var topSpaceConstraint: NSLayoutConstraint!
    var headerRefreshObserver: NSObjectProtocol?
    private var triggerOffset = CGFloat.infinity
    public var state: YQRefreshState = .default {
        didSet {
            guard oldValue != state else {
                return
            }
            actor?.state = state
        }
    }

    public weak var scrollView: UIScrollView? {
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
        
    public init(actor: YQRefreshActor? = YQRefreshActorProvider.shared.footerActor?() ?? FooterActor(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 100, height: YQRefresherHeight))), action: @escaping YQRefreshAction) {
        self.actor = actor
        self.action = action
            
        super.init(frame: CGRect.zero)
        if let actor = self.actor {
            addSubview(actor)
        }
        dealHeaderRefreshNotification()
    }
        
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    deinit {
        if let observer = headerRefreshObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
        
    override open func layoutSubviews() {
        super.layoutSubviews()
        guard let actor = actor else {
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
            var contentInset = scroll.contentInset
            contentInset.bottom += refresherHeight
            scroll.contentInset = contentInset
            scrollView = scroll
        } else {
            removeObservers(on: superview)
        }
    }
        
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if let scroll = scrollView {
            if context == UnsafeMutableRawPointer(&YQKVOContentOffset) {
                guard state != .noMore else {
                    return
                }
                guard state != .refreshing else {
                    return
                }
                let visibleMaxY = scroll.contentOffset.y + scroll.bounds.height
                guard visibleMaxY >= triggerOffset else {
                    return
                }
                if state != .refreshing {
                    if visibleMaxY > triggerOffset {
                        state = .refreshing
                        if let action = self.action {
                            action()
                        }
                    }
                }
            } else if context == UnsafeMutableRawPointer(&YQKVOContentSize) {
                let contentSize = change![NSKeyValueChangeKey.newKey] as! CGSize
                if contentSize.height < scroll.bounds.height {
                    topSpaceConstraint.constant = scroll.bounds.height + yOffset
                    triggerOffset = scroll.bounds.height + refresherHeight / 2
                } else {
                    topSpaceConstraint.constant = contentSize.height + yOffset
                    triggerOffset = contentSize.height + refresherHeight
                }
            }
        }
    }
        
    private var isVisiable: Bool {
        guard let scroll = scrollView else {
            return false
        }
        let visibleMaxY = scroll.contentOffset.y + scroll.bounds.height
        let footerTop = max(scroll.contentSize.height, scroll.bounds.height)
        return visibleMaxY > footerTop
    }
        
    private func dealHeaderRefreshNotification() {
        headerRefreshObserver = NotificationCenter.default.addObserver(forName: Notification.Name(YQNotificatonHeaderRefresh), object: nil, queue: nil) {[weak self] notificiation in
            guard let self = self, let view = notificiation.object as? UIScrollView, view == self.scrollView else {
                return
            }
            if self.state == .noMore {
                self.state = .default
            }
        }
    }
        
    // public
    public func beginRefreshing() {
        state = .refreshing
    }
        
    public func endRefreshing() {
        state = .default
    }
        
    public func noMore() {
        state = .noMore
    }
}
