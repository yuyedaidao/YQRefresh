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
            guard let a = actor else {
                return
            }
            if let old = oldValue {
                old.removeFromSuperview()
            }
            addSubview(a)
        }
    }
    public var action: YQRefreshAction?
    public var refresherHeight: CGFloat = YQRefresherHeight
    public var originalInset: UIEdgeInsets = UIEdgeInsets.zero
    public var pullingPercentOffset: CGFloat = YQRefresherHeight / 2
    public var yOffset: CGFloat = 0
    private var isAnimating = false
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
                    let contentOffset = scroll.contentOffset
                    scroll.setContentOffset(contentOffset, animated: false)
                    UIView.animate(withDuration: 0, animations: {}) { (_) in
                        UIView.animate(withDuration: YQRefresherAnimationDuration, animations: {
                            if scroll.bounds.height > scroll.contentSize.height + self.originalInset.bottom {
                                let bottom = scroll.bounds.height - scroll.contentSize.height + self.refresherHeight
                                scroll.contentInset.bottom = bottom
                                scroll.contentOffset.y = self.refresherHeight
                            } else {
                                let bottom = self.originalInset.bottom + self.refresherHeight
                                scroll.contentInset.bottom = bottom
                                scroll.contentOffset.y = scroll.contentSize.height - scroll.bounds.height + bottom
                            }
                        })
                    }
                }
            case .noMore:
                resetScrollView()
            case .pulling:
                guard let scrollView = scrollView, scrollView.isTracking else {
                    break
                }
                if #available(iOS 10.0, *) {
                    UIImpactFeedbackGenerator().impactOccurred()
                }
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
    
    public init (actor: YQRefreshActor? = YQRefreshActorProvider.shared.footerActor?() ?? FooterActor(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 100, height: YQRefresherHeight))), action: @escaping YQRefreshAction) {
        self.actor = actor
        self.action = action
        
        super.init(frame: CGRect.zero)
        if let actor = self.actor {
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
            scrollView = scroll
        } else {
            removeObservers(on: superview)
        }
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let scroll = scrollView {
            if context == UnsafeMutableRawPointer(&YQKVOContentOffset) {
                if !isAnimating {
                    isHidden = !isVisiable
                }
                guard state != .refreshing, state != .noMore else {
                    return
                }
                let visibleMaxY = scroll.contentOffset.y + scroll.bounds.height
                let contentBottom = max(scroll.contentSize.height + originalInset.bottom, scroll.bounds.height)
                guard visibleMaxY > contentBottom else {
                    return
                }
                let triggerOffset = contentBottom + refresherHeight
                if scroll.isDragging {
                    if state == .default && visibleMaxY >= triggerOffset{
                        state = .pulling
                    } else if state == .pulling && visibleMaxY < triggerOffset {
                        state = .default
                    }
                } else {
                    if state == .pulling {
                        if visibleMaxY >= triggerOffset {
                            state = .refreshing
                            if let action = self.action {
                                action()
                            }
                        } else {
                            state = .default
                        }
                    }
                }
                let percent = (visibleMaxY - contentBottom - pullingPercentOffset) / (refresherHeight - pullingPercentOffset)
                pullingPercent = max(min(Double(percent), 1), 0)
            } else if context == UnsafeMutableRawPointer(&YQKVOContentSize){
                let contentSize = change![NSKeyValueChangeKey.newKey] as! CGSize
                if contentSize.height + originalInset.bottom < scroll.bounds.height {
                    topSpaceConstraint.constant = scroll.bounds.height + yOffset
                } else {
                    topSpaceConstraint.constant = contentSize.height + originalInset.bottom + yOffset
                }
            }
        }
    }
    
    private var isVisiable: Bool  {
        guard let scroll = scrollView else {
            return false
        }
        let visibleMaxY = scroll.contentOffset.y + scroll.bounds.height
        let footerTop = max(scroll.contentSize.height + originalInset.bottom, scroll.bounds.height)
        return visibleMaxY > footerTop
    }
    
    private func resetScrollView() {
        if let scroll = scrollView, scroll.contentInset.bottom != originalInset.bottom {
            if !isVisiable {
                let bottom = self.originalInset.bottom
                scroll.contentInset.bottom = bottom
                return
            }
            isAnimating = true
            isHidden = false
            let contentOffset = scroll.contentOffset
            scroll.setContentOffset(contentOffset, animated: false)
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0) {} completion: { (_) in
                    UIView.animate(withDuration: YQRefresherAnimationDuration, animations: {
                        let bottom = self.originalInset.bottom
                        scroll.contentInset.bottom = bottom
                        // MARK: 下边注释的这句当时为什么这样处理来，没道理，现在去掉
//                        scroll.contentOffset.y = max(scroll.contentSize.height, scroll.bounds.height) - scroll.bounds.height + bottom
                    }) { (_) in
                        self.isAnimating = false
                        self.isHidden = true
                    }
                }
            }
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
        state = .refreshing
    }
    
    public func endRefreshing() {
        state = .default
    }
    
    public func noMore() {
        state = .noMore
    }
}
