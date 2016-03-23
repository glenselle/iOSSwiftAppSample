//
//  MessageTableViewCell.swift
//  Gecko iOS
//

import Foundation
import UIKit

class MessageTableViewCell: UITableViewCell, UIGestureRecognizerDelegate {

    var message: Message!
    var identifier: String!
    
    // Sub views
    var avatarView: UIView!
    var avatarImageView: UIImageView!
    
    var bubbleView: UIView!
    var bubbleLabel: UILabel!
    var bubbleImageView: UIImageView!
    
    var animatedBackgroundLayer: CALayer!
    var backgroundLayerAnimation: CABasicAnimation!
    
    // Message bubble values
    let avatarHeight = 35 as CGFloat
    let avatarWidth = 35 as CGFloat
    let avatarTopPadding = 10 as CGFloat
    let avatarLeftPadding = 10 as CGFloat
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    convenience init(style: UITableViewCellStyle, reuseIdentifier: String!, message: Message) {
        self.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.identifier = reuseIdentifier
        self.message = message
        
        self.selectionStyle = .None
        
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDidStopSelector(Selector("animationDidStop"))
        
        let messageTextSize = (message.text as NSString).boundingRectWithSize(CGSizeMake(200, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(15)], context: nil)

        // Register a tap gesture to show a context menu for each message
        let cellContextMenuTapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        cellContextMenuTapGesture.cancelsTouchesInView = false
        cellContextMenuTapGesture.delegate = self
        
        // Configure the label which contains the message text
        bubbleLabel = UILabel()
        bubbleLabel.numberOfLines = 0
        bubbleLabel.textColor = geckoDarkBlue
        bubbleLabel.font = UIFont(name: "Helvetica", size: 15)
        bubbleLabel.text = message.text
        bubbleLabel.addGestureRecognizer(cellContextMenuTapGesture)
        //bubbleLabel.backgroundColor = UIColor.grayColor() //--REMOVE
        
        // Configure the main bubble view which contains the label and background image
        bubbleView = UIView()
        bubbleView.backgroundColor = UIColor.clearColor()
        
        //bubbleView.layer.borderWidth = 1 //--REMOVE
        //bubbleView.layer.borderColor = UIColor.greenColor().CGColor //--REMOVE
        
        // Configure the image view which contains the bubble's background image
        bubbleImageView = UIImageView()
        bubbleImageView.layer.shouldRasterize = true
        bubbleImageView.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        // Left-aligned messages share some common properties--we set those here
        if identifier == "participantCell" || identifier == "participantMoneyCell" {
            
            // Configure the avatar view which contains the avatar image
            avatarView = UIView(frame: CGRectMake(0, 0, avatarWidth + avatarLeftPadding + 5, self.frame.size.height))
            avatarView.backgroundColor = UIColor.whiteColor()
            
            avatarImageView = UIImageView(frame: CGRectMake(avatarLeftPadding, avatarTopPadding, avatarWidth, avatarHeight))
            avatarImageView.image = UIImage(data: message.author.avatar)
            avatarImageView.layer.cornerRadius = avatarHeight / 2
            avatarImageView.clipsToBounds = true
            avatarView.addSubview(avatarImageView)
        }
        
        // Right-aligned messages share some common properties--we set those here
        if identifier == "userCell" || identifier == "userMoneyCell" {
            bubbleLabel.textColor = UIColor.whiteColor()
        }
        
        //self.layer.borderWidth = 1 //--REMOVE
        //self.layer.borderColor = UIColor.grayColor().CGColor //--REMOVE

        // Add the red background view to animate if it's a money message (we can configure separate background colors when animation depending on who is receiving/sending)
        if identifier == "userMoneyCell" {
            
            // Configure the red background for money messages
            animatedBackgroundLayer = CALayer()
            animatedBackgroundLayer.backgroundColor = geckoFiretruckRed.CGColor
            animatedBackgroundLayer.anchorPoint = CGPointMake(0, 0)
            
            // Adjust each view frame for user money cells
            drawUserFrames(messageTextSize)
            
            // Set the right backbground image for the cell
            bubbleImageView.image = UIImage(named: "userMoneyCell.png").resizableImageWithCapInsets(UIEdgeInsetsMake(25, 10, 5, 20))
            
            // If the message is "hot" then we generate an animation and add it to the background layer otherwise we just make a red background
            if message.hot {
                bubbleLabel.textColor = geckoDarkBlue
                animatedBackgroundLayer.frame = CGRectMake(1, 1, 0, bubbleImageView.frame.height - 4)
                backgroundLayerAnimation = generateAnimation(bubbleImageView.frame.width)
                animatedBackgroundLayer.addAnimation(backgroundLayerAnimation, forKey: "frameAnimation")
            } else {
                animatedBackgroundLayer.frame = CGRectMake(0, 0, bubbleImageView.frame.width, bubbleImageView.frame.height)
            }
            
            // Add the special red animated background to the message cell background
            bubbleView.layer.addSublayer(animatedBackgroundLayer)
            
            // Add the sub views
            bubbleView.addSubview(bubbleImageView)
            bubbleView.addSubview(bubbleLabel)
            self.addSubview(bubbleView)
        } else if identifier == "participantMoneyCell" {
            
            // Adjust each view frame for participant money cells
            drawParticipantFrames(messageTextSize)
            
            // Set the right backbground image for the cell
            bubbleImageView.image = UIImage(named: "participantMoneyCell.png").resizableImageWithCapInsets(UIEdgeInsetsMake(25, 20, 5, 10))
            
            // Add the special red animated background to the message cell background
            bubbleView.layer.addSublayer(animatedBackgroundLayer)
            
            // Add the sub views
            bubbleView.addSubview(bubbleImageView)
            bubbleView.addSubview(bubbleLabel)
            self.addSubview(bubbleView)
            self.addSubview(avatarView)
        } else if identifier == "userCell" {
            
            // Set the message text color
            bubbleLabel.textColor = UIColor.whiteColor()
            
            // Adjust each view frame for user cells
            drawUserFrames(messageTextSize)
            
            // Set the right backbground image for the cell
            bubbleImageView.image = UIImage(named: "userCell.png").resizableImageWithCapInsets(UIEdgeInsetsMake(25, 10, 5, 20))
            
            // Add the sub views
            bubbleView.addSubview(bubbleImageView)
            bubbleView.addSubview(bubbleLabel)
            self.addSubview(bubbleView)
        } else if identifier == "participantCell" {
            
            // Adjust each view frame for participant cells
            drawParticipantFrames(messageTextSize)
            
            // Set the right backbground image for the cell
            bubbleImageView.image = UIImage(named: "participantCell.png").resizableImageWithCapInsets(UIEdgeInsetsMake(25, 20, 5, 10))
            
            // Add the sub views
            bubbleView.addSubview(bubbleImageView)
            bubbleView.addSubview(bubbleLabel)
            self.addSubview(bubbleView)
            self.addSubview(avatarView)
        }
    }
    
    func drawUserFrames(size: CGRect) {
        bubbleLabel.frame = CGRectMake(10, 5, size.width + 5, size.height + 10)
        bubbleView.frame = CGRectMake(self.frame.size.width - size.width - 30, 10, self.frame.size.width - 70, bubbleLabel.frame.size.height + 10)
        bubbleImageView.frame = CGRectMake(0, 0, bubbleLabel.frame.size.width + 20, bubbleLabel.frame.size.height + 10)
    }
    
    func drawParticipantFrames(size: CGRect) {
        bubbleLabel.frame = CGRectMake(15, 5, size.width, size.height + 10)
        bubbleView.frame = CGRectMake(avatarWidth + avatarLeftPadding + 5, 10, self.frame.size.width - 70, bubbleLabel.frame.size.height + 10)
        bubbleImageView.frame = CGRectMake(0, 0, bubbleLabel.frame.size.width + 20, bubbleLabel.frame.size.height + 10)
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        NSLog("cell tapped")
        bubbleLabel.textColor = UIColor.blueColor()
    }
    
//    override func setHighlighted(highlighted: Bool, animated: Bool) {
//        let normalScale = 1 as CGFloat
//        let zoomedScale = 0.98 as CGFloat
//        
//        if(highlighted) {
//            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: nil, animations: { () -> Void in
//                self.transform = CGAffineTransformScale(CGAffineTransformIdentity, zoomedScale, zoomedScale);
//                }) { (Bool) -> Void in }
//        } else {
//            UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: nil, animations: { () -> Void in
//                self.transform = CGAffineTransformScale(CGAffineTransformIdentity, normalScale, normalScale);
//                }) { (Bool) -> Void in }
//        }
//    }
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        
        if flag {
            UIView.transitionWithView(bubbleLabel, duration: 0.25, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
                self.bubbleLabel.textColor = geckoDarkBlue
                self.bubbleLabel.textColor = UIColor.whiteColor()
            }, completion: { (done: Bool) -> Void in
                self.message.hot = false
            })
        }
    }
    
    override func prepareForReuse() {
        
        // Remove all current animations -- must be done before resizing the frames otherwise the backround is animated to the new frame bounds
        if let animatedBackgroundLayer = animatedBackgroundLayer {
            animatedBackgroundLayer.removeAllAnimations()
        }
    }
    
    func generateAnimation(width: CGFloat) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: "bounds.size.width")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.toValue = width
        animation.duration = 4.5
        animation.delegate = self
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        return animation
    }
    
    func reset(identifier: String, message: Message) {
        self.identifier = identifier
        self.message = message
        
        // Only left-aligned cells have avatars
        if identifier == "participantCell" || identifier == "participantMoneyCell" {
            avatarImageView.image = UIImage(data: message.author.avatar)
        }
        
        bubbleLabel.text = message.text
        
        let messageTextSize = (message.text as NSString).boundingRectWithSize(CGSizeMake(200, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(15)], context: nil)
        
        if identifier == "userMoneyCell" {
            
            
            
            // Reset the frames
            drawUserFrames(messageTextSize)
            
            // If the message is "hot" then we generate an animation and add it to the background layer otherwise we just make a red background
            if message.hot {
                bubbleLabel.textColor = geckoDarkBlue
                animatedBackgroundLayer.frame = CGRectMake(0, 0, 0, bubbleImageView.frame.height)
                backgroundLayerAnimation = generateAnimation(bubbleImageView.frame.width)
                animatedBackgroundLayer.addAnimation(backgroundLayerAnimation, forKey: "frameAnimation")
            } else {
                animatedBackgroundLayer.frame = CGRectMake(0, 0, bubbleImageView.frame.width, bubbleImageView.frame.height)
            }
        } else if identifier == "participantMoneyCell" {
            
            // Reset the frames
            drawParticipantFrames(messageTextSize)
        } else if identifier == "userCell" {
            
            // Reset the frames
            drawUserFrames(messageTextSize)
        } else if identifier == "participantCell" {
            
            // Reset the frames
            drawParticipantFrames(messageTextSize)
        }
    }
}