//
//  CustomRefreshHeader.swift
//  YQRefresh
//
//  Created by 王叶庆 on 2017/2/13.
//  Copyright © 2017年 王叶庆. All rights reserved.
//

import UIKit

class CustomActor: UIView, YQRefreshActor {
    
    var label: UILabel = UILabel()
    
    
    func setState(_ state: YQRefreshState) {
        switch state {
        case .default:
            break
        default:
            break
        }
    }
    
    func setPullingPrecent(_ present: Double) {
        
    }
    
}


class CustomRefreshHeader: YQRefreshHeader {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    init(_ action: @escaping YQRefreshAction) {
        super.init(nil, action)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
