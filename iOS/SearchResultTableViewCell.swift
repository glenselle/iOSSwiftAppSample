//
//  SearchResultTableViewCell.swift
//  Gecko iOS
//

import Foundation
import UIKit

class SearchResultTableViewCell: UITableViewCell {

    // Embedded Views
    var avatarImage: UIImage!
    var avatarView: UIImageView!
    var titleText: UILabel!
    var identifierText: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    convenience init(style: UITableViewCellStyle, reuseIdentifier: String!, result: SearchResult) {
        self.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Get the person's avatar
        avatarImage =  UIImage(named: "avatar") //UIImage(data: currentMessage.author.avatar)
        avatarView = UIImageView(image: avatarImage)
        avatarView.frame = CGRectMake(15, 5, 50, 50)
        avatarView.layer.cornerRadius = 25
        avatarView.layer.masksToBounds = true
        self.addSubview(avatarView)
        
        // Get the name of the person
        titleText = UILabel()
        titleText.text = result.titleLabel.capitalizedString
        titleText.frame = CGRectMake(75, 15, self.frame.width, 20)
        titleText.font = UIFont(name: "Helvetica", size: 16)
        titleText.textColor = geckoDarkBlue
        
        // Show an identifier like an email or phone number
        identifierText = UILabel()
        identifierText.frame = CGRectMake(75, 30, self.frame.width, 20)
        identifierText.font = UIFont(name: "Helvetica", size: 13)
        identifierText.textColor = geckoLightGreyText
        
        // Show email if available, otherwise their phone number
        if result.subTitleLabel != "" {
            identifierText.text = result.subTitleLabel
            self.addSubview(titleText)
            self.addSubview(identifierText)
        } else {
            titleText.frame = CGRectMake(75, 20, self.frame.width, 20)
            self.addSubview(titleText)
        }
    }
    
    func reset(result: SearchResult) {
        titleText.text = result.titleLabel.capitalizedString
        titleText.frame = CGRectMake(75, 15, self.frame.width, 20)
        
        // Show email if available, otherwise their phone number
        if result.subTitleLabel != "" {
            identifierText.hidden = false
            identifierText.text = result.subTitleLabel
        } else {
            identifierText.hidden = true
            titleText.frame = CGRectMake(75, 20, self.frame.width, 20)
        }
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
}