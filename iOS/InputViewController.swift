//
//  InputViewController.swift
//  Gecko iOS
//

import Foundation
import UIKit

class InputView: UIView, UITextFieldDelegate {
    
    var background: UIView!
    
    func render() {
        var inputField = UITextField()
        inputField.frame = CGRectMake(10, 10, self.frame.width - 100, 50)
        inputField.placeholder = "Send a message"
        inputField.layer.cornerRadius = 5
        inputField.clipsToBounds = true
        inputField.layer.borderWidth = 1.0
        inputField.layer.borderColor = geckoLightGreyText.CGColor
        
        inputField.delegate = self
        
        // Add two keyboard listeners
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide"), name: UIKeyboardWillHideNotification, object: nil)
        
        self.addSubview(inputField)
    }
    
    func keyboardWillShow(sender: AnyObject) {
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
    }
    
    // Textfield protcol implementations
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        NSLog("Done")
        return true
    }
}