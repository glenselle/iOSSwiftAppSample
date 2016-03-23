//
//  UncoverVerticalSegue.swift
//  Gecko iOS
//

import Foundation
import UIKit

class UncoverVerticalSegue: UIStoryboardSegue {
    
    override func perform() {
        var sourceViewController = self.sourceViewController as UIViewController
        var destinationViewController = self.destinationViewController as UIViewController
        var duplicatedSourceView: UIView = sourceViewController.view.snapshotViewAfterScreenUpdates(false) // Create a screenshot of the old view.
        
        /* We add a screenshot of the old view (Bottom) above the new one (Top), it looks like nothing changed. */
        destinationViewController.view.addSubview(duplicatedSourceView)
        
        /* Our main view is now destinationViewController. */
        sourceViewController.presentViewController(destinationViewController, animated: false, completion: {
            UIView.animateWithDuration(0.33, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut,
                animations: { () -> Void in
                    /*
                    This is the block affected by the animation. Duration: 0,33s. Options: Ease-Out speed curve.
                    We slide the old view's screenshot at the bottom of the screen.
                    */
                    duplicatedSourceView.transform = CGAffineTransformMakeTranslation(0, duplicatedSourceView.frame.size.height)
                },
                completion: { (finished: Bool) -> Void in
                    /* The animation is finished, we removed the old view's screenshot. */
                    duplicatedSourceView.removeFromSuperview()
            })
        })
    }
}