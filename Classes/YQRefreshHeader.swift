//
//  YQRefreshHeader.swift
//  YQRefresh
//
//  Created by 王叶庆 on 2017/2/10.
//  Copyright © 2017年 王叶庆. All rights reserved.
//

import UIKit

open class YQRefreshHeader: UIView, YQRefresher {
    
    
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
    private var isAnimated = false
    public var state: YQRefreshState = .default {
        didSet {
            guard oldValue != state else {
                return
            }
            switch state {
            case .default:
                if scrollView?.contentInset.top != originalInset.top {
                    isAnimated = true
                    isHidden = false
                    UIView.animate(withDuration: YQRefresherAnimationDuration, animations: {
                        let top = self.originalInset.top
                        self.scrollView?.contentInset.top = top
                        self.scrollView?.contentOffset.y = -top
                    }) { (_) in
                        self.isAnimated = false
                        self.isHidden = true
                    }
                }
            case .refreshing:
                UIView.animate(withDuration: YQRefresherAnimationDuration, animations: {
                    let top = self.refresherHeight + self.originalInset.top
                    self.scrollView?.contentInset.top = top
                    self.scrollView?.contentOffset.y = -top
                })
            case .pulling:
                guard let scrollView = scrollView, scrollView.isTracking else {
                    break
                }
                if #available(iOS 10.0, *) {
                    UIImpactFeedbackGenerator().impactOccurred()
                }
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
            }
        }
    }
    public var pullingPercent: Double = 0 {
        didSet {
            actor?.pullingPrecent = pullingPercent
        }
    }

    
    public func beginRefreshing() {
        pullingPercent = 1
        state = .refreshing
    }
    
    public func endRefreshing() {
        state = .default
        pullingPercent = 0
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let scroll = scrollView {
            let offsetY = scroll.contentOffset.y
            if !isAnimated {
                self.isHidden = (offsetY >= -originalInset.top)
            }
            guard state != .refreshing else {
                return
            }
            let triggerOffset = -originalInset.top - refresherHeight
            if scroll.isDragging {
                if state == .default && offsetY <= triggerOffset{
                    state = .pulling
                } else if state == .pulling && offsetY > triggerOffset {
                    state = .default
                }
            } else {
                if state == .pulling {
                    if offsetY <= triggerOffset + 10 { // 拉开一点距离，增大触发率
                        state = .refreshing
                        if let action = self.action {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: YQNotificatonHeaderRefresh), object: nil)
                            action()
                        }
                    } else {
                        state = .default
                    }
                }
            }
            guard offsetY < -originalInset.top else {
                return
            }
            let percent = (-originalInset.top - offsetY - pullingPercentOffset) / (refresherHeight - pullingPercentOffset)
            pullingPercent = max(min(Double(percent), 1), 0)
        }
    }

    public init (actor: YQRefreshActor? = YQRefreshActorProvider.shared.headerActor?() ?? PacmanActor(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 45, height: 30))), action: @escaping YQRefreshAction) {
        self.actor = actor
        self.action = action
        
        super.init(frame: CGRect.zero)
        if let a = actor {
            addSubview(a)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard let actor = actor else {
            return
        }
        actor.center = CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        func removeObservers(on view: UIView?) {
            view?.removeObserver(self, forKeyPath: YQKVOContentOffset, context: UnsafeMutableRawPointer(&YQKVOContentOffset))
        }
        if let scroll = newSuperview as? UIScrollView {
            scrollView = scroll
        } else {
            removeObservers(on: superview)
        }
        
    }
}
