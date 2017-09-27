//
//  YQRefreshHeader.swift
//  YQRefresh
//
//  Created by 王叶庆 on 2017/2/10.
//  Copyright © 2017年 王叶庆. All rights reserved.
//

import UIKit

open class YQRefreshHeader: UIView, YQRefresher {
    
    var actor: YQRefreshActor? {
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
            self.actor?.state = state
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
            self.actor?.pullingPrecent = pullingPercent
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
            let triggerOffset = -self.originalInset.top - self.refresherHeight
            if scroll.isDragging {
                if self.state == .default {
                    self.state = .pulling
                }
            } else {
                if self.state == .pulling {
                    if offsetY <= triggerOffset {
                        self.beginRefreshing()
                    } else if offsetY >= -self.originalInset.top  {
                        self.state = .default
                    }
                }
            }
            guard offsetY < -self.originalInset.top else {
                return
            }
            let percent = (-self.originalInset.top - offsetY - self.pullingPercentOffset) / (self.refresherHeight - self.pullingPercentOffset)
            self.pullingPercent = max(min(Double(percent), 1), 0)
        }
    }

    init (_ actor: YQRefreshActor? = PacmanActor(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 45, height: 30))), _ action: @escaping YQRefreshAction) {
        self.actor = actor
        self.action = action
        
        super.init(frame: CGRect.zero)
        if let a = self.actor as? UIView {
            self.addSubview(a)
        }
       
    }
    
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard let actor = self.actor as? UIView else {
            return
        }
        actor.center = CGPoint(x: bounds.midX, y: bounds.midY)
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
