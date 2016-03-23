//
//  UITransition.swift
//  Gecko iOS
//

import Foundation
import UIKit

class UITransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.50
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        
        //transitionContext.containerView().addSubview(toViewController?.view)

        toViewController?.view.alpha = 0
        
        UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: nil, animations: { () -> Void in

            fromViewController?.view.transform = CGAffineTransformMakeScale(0.1, 0.1)
            toViewController?.view.alpha = 1
            
        }) { (Bool) -> Void in
            
            fromViewController?.view.transform = CGAffineTransformIdentity
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
}