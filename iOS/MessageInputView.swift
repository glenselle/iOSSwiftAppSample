//
//  MessageInputView.swift
//  Gecko iOS
//

import Foundation
import UIKit

class MessageInputViewy: UIView, UITextFieldDelegate {
    
    var textBgImageView: UIImageView!
    var textView: UITextView!
    var sendButton: UIButton!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init()
        
        self.frame = frame
        
        //        self.autoresizingMask = .TopMargin | .Width
        
        let greyBorder = UIColor(red:233.0/255, green:233.0/255, blue:233.0/255, alpha:1)
        //_findUser = [NSRegularExpression regularExpressionWithPattern:@"(\\$(\\d+\\.?\\d?\\d?)\\ ?@)(.+)?" options:NSRegularExpressionCaseInsensitive error:nil ];
        //inputAccessoryForFindingKeyboard = [[UIView alloc] initWithFrame:CGRectZero];
        
        // Give the view a white background so we don't see messages through it
        self.layer.backgroundColor = UIColor.whiteColor().CGColor
        
        // Set a top border on the view
        self.layer.borderColor = UIColor.whiteColor().CGColor
        self.layer.borderWidth = 1.0
        
        var topBorder = CALayer()
        topBorder.borderColor = greyBorder.CGColor
        topBorder.borderWidth = 1.0
        topBorder.frame = CGRectMake(-1.0, -1.0, self.layer.frame.size.width + 2.0, self.layer.frame.size.height);
        
        self.layer.addSublayer(topBorder)
        
        // The text view padding/background view
        textBgImageView.layer.backgroundColor = UIColor.whiteColor().CGColor
        textBgImageView.layer.borderColor = greyBorder.CGColor
        textBgImageView.layer.cornerRadius = 5.0
        textBgImageView.layer.borderWidth = 1.0
        //self.textBgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.addSubview(textBgImageView)
        
        // Text input view
        textView.textColor = UIColor.blackColor()
        //textView.delegate = self
        textView.backgroundColor = UIColor.clearColor()
        textView.textContainer.lineFragmentPadding = 0
        //self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //self.textView.inputAccessoryView = inputAccessoryForFindingKeyboard;
        //textView.placeholderText = "Type a message"
        
        //textView.setTextContainerInset(UIEdgeInsetsZero)
        textView.font = UIFont(name: "Helvetica", size: 16)
        
        self.addSubview(textView)
        
        // Send button styles
        var grey = UIColor(red:226.0/255, green:226.0/255, blue:226.0/255, alpha:1)
        var darkGrey = UIColor(red:174.0/255, green:174.0/255, blue:174.0/255, alpha:1)
        
        sendButton.layer.cornerRadius = 5.0
        sendButton.backgroundColor = grey;
        //sendButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        sendButton.frame = CGRectMake(0, 0, 50, 40);
        
        sendButton.setTitleColor(darkGrey, forState:.Normal)
        //sendButton.addTarget(self, action: Selector(sendTapped), forControlEvents: .TouchUpInside)
        sendButton.setTitle("SEND", forState:.Normal)
        
        self.addSubview(sendButton)
        
        // Paperclip attachment button styles
        //        self.mediaButton = [UIButton buttonWithType:UIButtonTypeCustom];
        //        self.mediaButton.contentMode = UIViewContentModeScaleAspectFit;
        //        self.mediaButton.frame = CGRectMake(0, 0, 50, 24);
        //        self.mediaButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        //        self.mediaButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        //
        //        [self.mediaButton addTarget:self action:@selector(mediaTapped:) forControlEvents:UIControlEventTouchUpInside];
        //        [self.mediaButton setImage:[UIImage imageNamed:@"attachment.png"] forState:UIControlStateNormal];
        //
        // We don't support attachments yet, so we don't show this
        //[self addSubview:self.mediaButton];
        
        // Searator View
        //        self.separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 0.5f)];
        //        self.separatorView.backgroundColor = [UIColor lightGrayColor];
        //        self.separatorView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        //        
        //        [self addSubview:self.separatorView];
        //

    }

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        NSLog("textFieldDidBeginEditing")
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        NSLog("textFieldDidEndEditing")
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
}