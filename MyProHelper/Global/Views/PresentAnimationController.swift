//
//  PresentAnimationController.swift
//  MyProHelper
//
//  Created by Benchmark Computing on 24/07/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit

class PresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let originFrame: CGRect
    
    init(originFrame: CGRect) {
      self.originFrame = originFrame
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to),
            let snapshot = toVC.view.snapshotView(afterScreenUpdates: true)
        else {
                return
        }
        
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)
        snapshot.frame = CGRect(x: finalFrame.maxX, y: 0, width: finalFrame.width, height: finalFrame.height)
        toVC.view.isHidden = true
        
        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot)
//        toVC.view.isHidden = true
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.9, animations: {
                snapshot.frame.origin.x = snapshot.frame.origin.x/2
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 0.1, animations: {
                snapshot.frame.origin.x = 0
            })
            
        }) { (_) in
            snapshot.removeFromSuperview()
            toVC.view.isHidden = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
}
