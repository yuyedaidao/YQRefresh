//
//  PacmanActor.swift
//  YQRefresh
//
//  Created by Wang on 2017/9/27.
//  Copyright © 2017年 王叶庆. All rights reserved.
//

import UIKit

class PacmanActor: UIView, YQRefreshActor {
    var state: YQRefreshState = .default {
        didSet {
            switch state {
            case .default:
                stopAnimation()
            case .refreshing:
                startAnimation()
                break
            default:
                break
            }
            print(state)
        }
    }
    
    var pullingPrecent: Double = 0 {
        didSet {
            if state == .pulling {
                mouthSize = pullingPrecent
            }
        }
    }
    var pacmanLayer: CAShapeLayer!
    var circleLayer: CAShapeLayer!
    var pacmanAnimation: CAAnimation!
    var circleAnimation: CAAnimation!
    var color: UIColor = UIColor.red {
        didSet {
            pacmanLayer.fillColor = color.cgColor
            circleLayer.fillColor = color.cgColor
        }
    }
    var mouthSize: Double = 0 {
        didSet {
            if let layer = self.pacmanLayer { 
                let path: UIBezierPath = UIBezierPath()
                let size = layer.bounds.size
                let angle = CGFloat((min(max(mouthSize, 0.2), 1)-0.2)/0.7 * (Double.pi / 2)/2)
                
                path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2), radius: size.width / 4, startAngle: angle, endAngle: angle > 0 ? -angle : CGFloat.pi * 2, clockwise: true)
                
                self.pacmanLayer.path = path.cgPath
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpAnimation(in: self.layer, size: frame.size, color: color)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpAnimation(`in` layer: CALayer, size: CGSize, color: UIColor) {
        let info = circle(in: layer, size: size, color: color)
        self.circleLayer = info.0
        self.circleAnimation = info.1
        let pInfo = pacman(in: layer, size: size, color: color)
        self.pacmanLayer = pInfo.0
        self.pacmanAnimation = pInfo.1
    }
    
    func pacman(`in` layer: CALayer, size: CGSize, color: UIColor) -> (CAShapeLayer,CAAnimation){
        let pacmanSize = 2 * size.width / 3
        let pacmanDuration: CFTimeInterval = 0.5
        let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        
        let strokeStartAnimation = CAKeyframeAnimation(keyPath: "strokeStart")
        
        strokeStartAnimation.keyTimes = [0, 0.5, 1]
        strokeStartAnimation.timingFunctions = [timingFunction, timingFunction]
        strokeStartAnimation.values = [0.125, 0, 0.125]
        strokeStartAnimation.duration = pacmanDuration
        
        // Stroke end animation
        let strokeEndAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
        
        strokeEndAnimation.keyTimes = [0, 0.5, 1]
        strokeEndAnimation.timingFunctions = [timingFunction, timingFunction]
        strokeEndAnimation.values = [0.875, 1, 0.875]
        strokeEndAnimation.duration = pacmanDuration
        
        // Animation
        let animation = CAAnimationGroup()
        
        animation.animations = [strokeStartAnimation, strokeEndAnimation]
        animation.duration = pacmanDuration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw pacman
        let pacman = createLayer(with: CGSize(width: pacmanSize, height: pacmanSize), color: color)
        let frame = CGRect(
            x: (layer.bounds.size.width - size.width) / 2,
            y: (layer.bounds.size.height - size.height) / 2 + size.height / 2 - pacmanSize / 2,
            width: pacmanSize,
            height: pacmanSize
        )
        pacman.frame = frame
        layer.addSublayer(pacman)
        return (pacman,animation)
    }
    
    func createLayer(with size: CGSize, color: UIColor) -> CAShapeLayer {
        let layer: CAShapeLayer = CAShapeLayer()
        let path: UIBezierPath = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                              radius: size.width / 4,
                              startAngle: 0,
                              endAngle: CGFloat(2 * Double.pi),
                              clockwise: true);
        layer.fillColor = nil
        layer.strokeColor = color.cgColor
        layer.lineWidth = size.width / 2
        layer.backgroundColor = nil
        layer.path = path.cgPath
        return layer
    }
    
    
    
    func circle(`in` layer: CALayer, size: CGSize, color: UIColor) -> (CAShapeLayer,CAAnimation){
        let circleSize = size.width / 5
        let circleDuration: CFTimeInterval = 1
        // Translate animation
        let translateAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        translateAnimation.fromValue = 0
        translateAnimation.toValue = -size.width / 2
        translateAnimation.duration = circleDuration
        // Opacity animation
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0.7
        opacityAnimation.duration = circleDuration
        
        // Animation
        let animation = CAAnimationGroup()
        animation.animations = [translateAnimation, opacityAnimation]
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = circleDuration
        animation.repeatCount = HUGE
        animation.isRemovedOnCompletion = false
        
        // Draw circles
        let circle = createCircleLayer(size: CGSize(width: circleSize, height: circleSize), color: color)
        let frame = CGRect(
            x: (layer.bounds.size.width - size.width) / 2 + size.width - circleSize,
            y: (layer.bounds.size.height - size.height) / 2 + size.height / 2 - circleSize
                / 2,
            width: circleSize,
            height: circleSize
        )
        
        circle.frame = frame
        layer.addSublayer(circle)
        
        return (circle,animation)
    }
    
    func createCircleLayer(size: CGSize, color: UIColor) -> CAShapeLayer {
        let layer: CAShapeLayer = CAShapeLayer()
        let path: UIBezierPath = UIBezierPath()
        path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                              radius: size.width / 2,
                              startAngle: 0,
                              endAngle: 2 * CGFloat.pi,
                              clockwise: false);
        layer.fillColor = color.cgColor
        layer.backgroundColor = nil
        layer.path = path.cgPath
        return layer
    }
    
    func startAnimation() {
        let path: UIBezierPath = UIBezierPath()
        let size = pacmanLayer.bounds.size
        path.addArc(withCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                              radius: size.width / 4,
                              startAngle: 0,
                              endAngle: 2 * CGFloat.pi,
                              clockwise: true);
        self.pacmanLayer.path = path.cgPath
        self.pacmanLayer.add(pacmanAnimation, forKey: "animation")
        self.circleLayer.add(circleAnimation, forKey: "animation")
    }
    
    func stopAnimation() {
        self.circleLayer.removeAllAnimations()
        self.pacmanLayer.removeAllAnimations()
    }
    
}


