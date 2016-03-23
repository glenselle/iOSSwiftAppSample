//
//  ThreadTableViewCell.swift
//  Gecko iOS
//

import Foundation
import UIKit

class ThreadTableViewCell: UITableViewCell, UIGestureRecognizerDelegate {
    
    var thread: Thread!
    var message: Message!
    var identifier: String!
    
    var avatarImage: UIImage!
    var avatarView: UIImageView!
    var titleText: UILabel!
    var messageText: UITextView!
    var dateText: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    convenience init(style: UITableViewCellStyle, reuseIdentifier: String!, thread: Thread) {
        self.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.thread = thread
        self.identifier = reuseIdentifier
        message = thread.conversation[0] as Message
        
        self.selectionStyle = .None
        
        // Configure the swipe gesture
//        let swipeGesture = UIPanGestureRecognizer(target: self, action: "handleSwipe:")
//        swipeGesture.delegate = self
//        swipeGesture.translationInView(self)
//        self.addGestureRecognizer(swipeGesture)
        
        // Get the person's avatar
        avatarImage = UIImage(data: message.author.avatar)
        avatarView = UIImageView(image: avatarImage)
        avatarView.frame = CGRectMake(15, 15, 70, 70)
        avatarView.layer.cornerRadius = 35
        avatarView.layer.masksToBounds = true
        self.addSubview(avatarView)
        
        // Get the title of the thread
        titleText = UILabel()
        titleText.text = thread.name.capitalizedString
        titleText.frame = CGRectMake(95, 15, 300, 30)
        titleText.font = UIFont(name: "Helvetica-Bold", size: 15)
        titleText.textColor = geckoDarkBlue
        
//        if indexPath.row == 1 {
//            titleText.textColor = UIColor.blackColor()
//        }
        
        
        // Get the first message's text property to display the most recent message
        messageText = UITextView()
        messageText.text = message.text
        messageText.frame = CGRectMake(90, 30, 300 - 95 + 10, 60)
        messageText.font = UIFont(name: "Helvetica", size: 15)
        messageText.textColor = geckoLightGreyText
        messageText.backgroundColor = UIColor.clearColor()
        
        messageText.userInteractionEnabled = false
        messageText.scrollEnabled = false
        messageText.clipsToBounds = true
        messageText.layer.masksToBounds = true
        
        // This is completely abritary and will be removed after the design review
//        if indexPath.row == 1 {
//            messageText.textColor = UIColor.blackColor()
//            messageText.font = UIFont(name: "Helvetica-Bold", size: 15)
//            
//            let dotWidth = 10 as CGFloat
//            let xCoord = -(dotWidth / 2) as CGFloat
//            let yCoord = 45 as CGFloat //(cell.frame.height / 2) as CGFloat
//            let dot = UIView(frame: CGRectMake(xCoord, yCoord + xCoord, dotWidth, dotWidth))
//            dot.backgroundColor = geckoFiretruckRed
//            dot.layer.cornerRadius = dotWidth / 2
//            cell.addSubview(dot)
//        }
        
        
        // Set the date label in the top right corner
        dateText = UILabel()
        dateText.text = Utilities.dateToMonthDayString(message.lastUpdated)
        dateText.frame = CGRectMake(230, -2, 80, 30)
        dateText.font = UIFont(name: "Helvetica", size: 10)
        dateText.textColor = geckoLightGreyText
        dateText.textAlignment = .Right
        
        self.addSubview(titleText)
        self.addSubview(messageText)
        self.addSubview(dateText)
    }
    
    func handleSwipe(recognizer: UIPanGestureRecognizer) {
    
        let translation = recognizer.translationInView(self)
        NSLog("translation size: \(translation) new : \(CGPointMake(self.center.x + translation.x, self.center.y))")
        self.center = CGPointMake(self.center.x + translation.x, self.center.y)
    }
    
    func reset(identifier: String, thread: Thread) {
        self.thread = thread
        self.identifier = reuseIdentifier
        message = thread.conversation[0] as Message
        
        avatarImage = UIImage(data: message.author.avatar)
        titleText.text = thread.name.capitalizedString
        messageText.text = message.text
        dateText.text = Utilities.dateToMonthDayString(message.lastUpdated)
    }
    
    override func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        let normalScale = 1 as CGFloat
        let zoomedScale = 0.98 as CGFloat
        
        if(highlighted) {
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: nil, animations: { () -> Void in
                self.transform = CGAffineTransformScale(CGAffineTransformIdentity, zoomedScale, zoomedScale);
                }) { (Bool) -> Void in }
        } else {
            UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: nil, animations: { () -> Void in
                self.transform = CGAffineTransformScale(CGAffineTransformIdentity, normalScale, normalScale);
                }) { (Bool) -> Void in }
        }
    }
}