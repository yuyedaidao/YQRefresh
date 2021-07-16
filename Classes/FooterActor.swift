//
//  FooterActor.swift
//  YQRefresh
//
//  Created by Wang on 2017/9/28.
//  Copyright © 2017年 王叶庆. All rights reserved.
//

import UIKit

public class FooterActor: UIView, YQRefreshActor {
    public var state: YQRefreshState = .default {
        didSet {
            if oldValue != state {
                textLabel.text = titles[state]
                switch state {
                case .default:
                    indicator.stopAnimating()
                case .pulling:
                    indicator.stopAnimating()
                case .noMore:
                    indicator.stopAnimating()
                case .refreshing:
                    indicator.startAnimating()
                }
            }
        }
    }
    public var pullingPrecent: Double = 0
    
    var textLabel: UILabel!
    var indicator: UIActivityIndicatorView!
    
    var titles:[YQRefreshState : String] = [.default: "加载更多",
                                            .pulling: "加载更多",
                                            .refreshing: "加载中...",
                                            .noMore: "暂无更多"
                                            ]
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        prepareViews()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        prepareViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func prepareViews() {
        textLabel = UILabel()
        textLabel.text = titles[.default]
        textLabel.textColor = UIColor.gray
        textLabel.font = UIFont.systemFont(ofSize: 13)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textLabel)
        addConstraint(NSLayoutConstraint(item: textLabel!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: textLabel!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        indicator = UIActivityIndicatorView(style: .gray)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicator)
        addConstraint(NSLayoutConstraint(item: indicator!, attribute: .centerY, relatedBy: .equal, toItem: textLabel, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: textLabel!, attribute: .leading, relatedBy: .equal, toItem: indicator, attribute: .trailing, multiplier: 1, constant: 4))
    }
    
}
