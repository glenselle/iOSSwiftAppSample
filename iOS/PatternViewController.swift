//
//  PatternViewController.swift
//  Gecko iOS
//

import Foundation
import AudioToolbox
import Realm

class PatternViewController: UIViewController {
    
    var message: Message!
    
    @IBOutlet weak var confirmationMessage: UILabel!
    @IBOutlet weak var legaleseLink: UIButton!
    
    var configurePatternMode = false
    var setAttempts = 0
    var verificationAttempts = 0
    
    let circleRedColor = UIColor(red: 254.0/255, green: 71.0/255, blue: 89.0/255, alpha: 1)
    let circleGreenColor = UIColor(red: 148.0/255, green: 221.0/255, blue: 204.0/255, alpha: 1)
    let circleBlueColor = UIColor(red: 44.0/255, green: 90.0/255, blue: 103.0/255, alpha: 1)
    let circleYellowColor = UIColor(red: 255.0/255, green: 225.0/255, blue: 68.0/255, alpha: 1)
    
    // Pattern value
    var patternValue = ""
    var setPatternValueOne = ""
    
    // Toggle circle state dictionary
    var toggleDict: Dictionary<String, Bool> = [
        "topLeft": false,
        "topMiddle": false,
        "topRight": false,
        "centerLeft": false,
        "centerMiddle": false,
        "centerRight": false,
        "bottomLeft": false,
        "bottomMiddle": false,
        "bottomRight": false,
    ]
    
    // Dots
    var topLeft: UIView!
    var topMiddle: UIView!
    var topRight: UIView!
    var centerLeft: UIView!
    var centerMiddle: UIView!
    var centerRight: UIView!
    var bottomLeft: UIView!
    var bottomMiddle: UIView!
    var bottomRight: UIView!
    
    // Dot view array
    var dotViewArray: Array<UIView>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prevent the title from showing next to the back button
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = emptyBackButtonFix
        
        drawDots()
        
        // Only show the confirmation message if we're dealing with a message
        if configurePatternMode {
            confirmationMessage.text = "Draw a new secret pattern"
            legaleseLink.hidden = true
        } else {
            confirmationMessage.text = createConfirmationMessage()
        }
    }
    
    func setMessage(composedMessage: Message) {
        message = composedMessage
    }
    
    func setConfigurationMode(mode: Bool) {
        configurePatternMode = mode
    }
    
    func drawDots() {
        let topOffset = 160 as CGFloat
        
        // Top left bubble
        topLeft = UIView(frame: CGRectMake(60, topOffset, 40, 40))
        topLeft.backgroundColor = circleRedColor
        topLeft.layer.shouldRasterize = true
        topLeft.layer.rasterizationScale = UIScreen.mainScreen().scale
        topLeft.alpha = 0.4
        topLeft.layer.cornerRadius = 20
        view.addSubview(topLeft)
        
        // Top middle bubble
        topMiddle = UIView(frame: CGRectMake(140, topOffset, 40, 40))
        topMiddle.backgroundColor = circleGreenColor
        topMiddle.layer.shouldRasterize = true
        topMiddle.layer.rasterizationScale = UIScreen.mainScreen().scale
        topMiddle.alpha = 0.4
        topMiddle.layer.cornerRadius = 20
        view.addSubview(topMiddle)
        
        // Top right bubble
        topRight = UIView(frame: CGRectMake(220, topOffset, 40, 40))
        topRight.backgroundColor = circleBlueColor
        topRight.layer.shouldRasterize = true
        topRight.layer.rasterizationScale = UIScreen.mainScreen().scale
        topRight.alpha = 0.4
        topRight.layer.cornerRadius = 20
        view.addSubview(topRight)
        
        // Center left bubble
        centerLeft = UIView(frame: CGRectMake(60, topOffset + 80, 40, 40))
        centerLeft.backgroundColor = circleYellowColor
        centerLeft.layer.shouldRasterize = true
        centerLeft.layer.rasterizationScale = UIScreen.mainScreen().scale
        centerLeft.alpha = 0.4
        centerLeft.layer.cornerRadius = 20
        view.addSubview(centerLeft)
        
        // Center middle bubble
        centerMiddle = UIView(frame: CGRectMake(140, topOffset + 80, 40, 40))
        centerMiddle.backgroundColor = circleBlueColor
        centerMiddle.layer.shouldRasterize = true
        centerMiddle.layer.rasterizationScale = UIScreen.mainScreen().scale
        centerMiddle.alpha = 0.4
        centerMiddle.layer.cornerRadius = 20
        view.addSubview(centerMiddle)
        
        // Center right bubble
        centerRight = UIView(frame: CGRectMake(220, topOffset + 80, 40, 40))
        centerRight.backgroundColor = circleRedColor
        centerRight.layer.shouldRasterize = true
        centerRight.layer.rasterizationScale = UIScreen.mainScreen().scale
        centerRight.alpha = 0.4
        centerRight.layer.cornerRadius = 20
        view.addSubview(centerRight)
        
        // Bottom left bubble
        bottomLeft = UIView(frame: CGRectMake(60, topOffset + 160, 40, 40))
        bottomLeft.backgroundColor = circleRedColor
        bottomLeft.layer.shouldRasterize = true
        bottomLeft.layer.rasterizationScale = UIScreen.mainScreen().scale
        bottomLeft.alpha = 0.4
        bottomLeft.layer.cornerRadius = 20
        view.addSubview(bottomLeft)
        
        // Bottom middle bubble
        bottomMiddle = UIView(frame: CGRectMake(140, topOffset + 160, 40, 40))
        bottomMiddle.backgroundColor = circleGreenColor
        bottomMiddle.layer.shouldRasterize = true
        bottomMiddle.layer.rasterizationScale = UIScreen.mainScreen().scale
        bottomMiddle.alpha = 0.4
        bottomMiddle.layer.cornerRadius = 20
        view.addSubview(bottomMiddle)
        
        // Bottom right bubble
        bottomRight = UIView(frame: CGRectMake(220, topOffset + 160, 40, 40))
        bottomRight.backgroundColor = circleYellowColor
        bottomRight.layer.shouldRasterize = true
        bottomRight.layer.rasterizationScale = UIScreen.mainScreen().scale
        bottomRight.alpha = 0.4
        bottomRight.layer.cornerRadius = 20
        view.addSubview(bottomRight)
        
        // Fill the dot view array
        dotViewArray = [topLeft, topMiddle, topRight, centerLeft, centerMiddle, centerRight, bottomLeft, bottomMiddle, bottomRight]
    }
    
    func createConfirmationMessage() -> String {
        let trans = message.transactions[0] as Transaction
        return "Draw your pattern to confirm you'd like to zip $\(trans.amount) to \(trans.toUser.name.capitalizedString)"
    }
    
    func handleTouch(event: UIEvent) {
        let touch = event.allTouches()?.anyObject() as UITouch
        let touchLocation = touch.locationInView(view)
        
        let topLeftFrame = topLeft.frame
        let topMiddleFrame = topMiddle.frame
        let topRightFrame = topRight.frame
        let centerLeftFrame = centerLeft.frame
        let centerMiddleFrame = centerMiddle.frame
        let centerRightFrame = centerRight.frame
        let bottomLeftFrame = bottomLeft.frame
        let bottomMiddleFrame = bottomMiddle.frame
        let bottomRightFrame = bottomRight.frame

        if CGRectContainsPoint(topLeftFrame, touchLocation) {
            if toggleDict["topLeft"] == false {
                patternValue += "1"
                toggleDict["topLeft"] = true
                popCircle(topLeft)
            }
        } else if CGRectContainsPoint(topMiddleFrame, touchLocation) {
            if toggleDict["topMiddle"] == false {
                patternValue += "2"
                toggleDict["topMiddle"] = true
                popCircle(topMiddle)
            }
        } else if CGRectContainsPoint(topRightFrame, touchLocation) {
            if toggleDict["topRight"] == false {
                patternValue += "3"
                toggleDict["topRight"] = true
                popCircle(topRight)
            }
        } else if CGRectContainsPoint(centerLeftFrame, touchLocation) {
            if toggleDict["centerLeft"] == false {
                patternValue += "4"
                toggleDict["centerLeft"] = true
                popCircle(centerLeft)
            }
        } else if CGRectContainsPoint(centerMiddleFrame, touchLocation) {
            if toggleDict["centerMiddle"] == false {
                patternValue += "5"
                toggleDict["centerMiddle"] = true
                popCircle(centerMiddle)
            }
        } else if CGRectContainsPoint(centerRightFrame, touchLocation) {
            if toggleDict["centerRight"] == false {
                patternValue += "6"
                toggleDict["centerRight"] = true
                popCircle(centerRight)
            }
        } else if CGRectContainsPoint(bottomLeftFrame, touchLocation) {
            if toggleDict["bottomLeft"] == false {
                patternValue += "7"
                toggleDict["bottomLeft"] = true
                popCircle(bottomLeft)
            }
        } else if CGRectContainsPoint(bottomMiddleFrame, touchLocation) {
            if toggleDict["bottomMiddle"] == false {
                patternValue += "8"
                toggleDict["bottomMiddle"] = true
                popCircle(bottomMiddle)
            }
        } else if CGRectContainsPoint(bottomRightFrame, touchLocation) {
            if toggleDict["bottomRight"] == false {
                patternValue += "9"
                toggleDict["bottomRight"] = true
                popCircle(bottomRight)
            }
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        handleTouch(event)
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        handleTouch(event)
    }
    
    func popCircle(dot: UIView) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.6, options: nil, animations: { () -> Void in
            let transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2)
            
            dot.transform = transform
            dot.alpha = 1
        }) {
            if $0 {
                NSLog("done")
            }
        }
    }
    
    func resetPattern() {
        patternValue = ""
        
        for (dotView, toggleState) in toggleDict {
            toggleDict[dotView] = false
        }
        
        UIView.animateWithDuration(0.3, delay: 0, options: nil, animations: { () -> Void in
            let transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0)
            
            for dot in self.dotViewArray {
                dot.transform = transform
                dot.alpha = 0.4
            }

        }) {
            if $0 {
                NSLog("done")
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
                
        if segue.identifier == "unwindPatternVerification" {
            
            // Get destination view
            let destinationView = segue.destinationViewController as MessagingViewController
            
            // Pass the information to your destination view
            destinationView.setIncomingMessage(message)
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if configurePatternMode && setPatternValueOne == "" {
            setPatternValueOne = patternValue
            
            confirmationMessage.text = "Perfect. Draw your pattern once more so we know we got it right"
            
            resetPattern()
        } else if configurePatternMode && setPatternValueOne != "" {
            if patternValue == setPatternValueOne {
                confirmationMessage.text = "Got it."
                
                let patternPayload = ["pattern": patternValue]
                API.sharedInstance.POST("pattern", payload: patternPayload, completionblock: {(error: NSError?, finalResponse: NSDictionary) -> () in
                    
                    // One second delay so people see the confirmation message
                    Utilities.delay(0.0) {
                        
                        self.resetPattern()
                        
                        self.navigationController?.popViewControllerAnimated(true)
                        
                        return
                    }
                })
            } else {
                setPatternValueOne = ""
                
                confirmationMessage.text = "Whoops, you entered a different pattern each time. Try again."
                
                // Vibrate the user's device when it's wrong
                AudioServicesPlaySystemSound(1352)
                
                resetPattern()
            }
        } else {
            
            let patternPayload = ["pattern": patternValue]
            API.sharedInstance.POST("pattern/verify", payload: patternPayload, completionblock: {(error: NSError?, finalResponse: NSDictionary) -> () in

                // If there's an auth_code, the pattern must be right
                if finalResponse.objectForKey("auth_code") != nil {
                    
                    self.confirmationMessage.text = "Perfect"
                    
                    self.resetPattern()
                    
                    // One second delay so people see the confirmation message
                    Utilities.delay(0.8) {
                        
                        self.performSegueWithIdentifier("unwindPatternVerification", sender: self)
                        
                        return
                    }
                } else {
                    
                    // One second delay so people see the confirmation message
                    Utilities.delay(0.0) {
                        
                        // Vibrate the user's device when it's wrong
                        AudioServicesPlaySystemSound(1352)
                        
                        self.resetPattern()
                        
                        return
                    }
                }
            })
        }
    }
}