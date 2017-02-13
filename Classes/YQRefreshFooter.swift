//
//  YQRefreshFooter.swift
//  YQRefresh
//
//  Created by 王叶庆 on 2017/2/13.
//  Copyright © 2017年 王叶庆. All rights reserved.
//

import UIKit

open class YQRefreshFooter: UIView, YQRefresher {

    var actor: YQRefreshActor?
    var action: YQRefreshAction?
    var refresherHeight: CGFloat = YQRefresherHeight
    var originalInset: UIEdgeInsets = UIEdgeInsets.zero
    var pullingPercentOffset: CGFloat = YQRefresherHeight / 2
    
    var state: YQRefreshState = .default {
        didSet {
            switch state {
            case .default:
                if let scroll = self.scrollView, scroll.contentInset.bottom != self.originalInset.bottom {
                    UIView.animate(withDuration: YQRefresherAnimationDuration, animations: {
                        let bottom = self.originalInset.bottom
                        scroll.contentInset.top = bottom
                        scroll.contentOffset.y = scroll.contentSize.height - scroll.bounds.height + bottom
                    })
                }
            case .refreshing:
                if let scroll = self.scrollView, scroll.contentInset.bottom != self.originalInset.bottom {
                    UIView.animate(withDuration: YQRefresherAnimationDuration, animations: {
                        let bottom = self.originalInset.bottom + self.refresherHeight
                        scroll.contentInset.top = bottom
                        scroll.contentOffset.y = scroll.contentSize.height - scroll.bounds.height + bottom
                    }, completion: { (isFinished) in
                        if let action = self.action {
                            action()
                        }
                    })
                }
                
            default:
                break
            }
            self.actor?.setState(state)
        }
    }
    weak var scrollView: UIScrollView? {
        didSet {
            if let scroll = scrollView {
                scroll.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
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
            guard state != .refreshing, state != .noMore else {
                return
            }
            let contentBottom = scroll.contentOffset.y + scroll.bounds.height
            guard contentBottom < self.originalInset.bottom + scroll.bounds.height else {
                return
            }
            
            let percent = (scroll.contentSize.height + self.originalInset.bottom - contentBottom - self.pullingPercentOffset) / (self.refresherHeight - self.pullingPercentOffset)
            self.pullingPercent = max(min(Double(percent), 1), 0)
            if scroll.isDragging {
                let triggerOffset = self.originalInset.bottom + scroll.contentSize.height + self.refresherHeight
                if self.state == .default && contentBottom <= triggerOffset{
                    self.state = .pulling
                } else if self.state == .pulling && contentBottom > triggerOffset{
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

}
