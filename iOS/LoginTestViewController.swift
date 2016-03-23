//
//  LoginTestViewController.swift
//  Gecko iOS
//
//  Created by Jordan Amman on 10/30/14.
//  Copyright (c) 2014 Zipline, inc. All rights reserved.
//

import Foundation
import UIKit

class LoginTestViewController: UIViewController, UITextFieldDelegate {
    
    //Login form
    @IBOutlet weak var logInForm: UIView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var loginEmailOrPhone: UITextField!
    
    
    // Register Form
    @IBOutlet weak var registerForm: UIView!
    @IBOutlet weak var createAcctBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        NSLog("\(loginEmailOrPhone)")
        NSLog("\(self.logInForm.center.y)")
        NSLog("\(loginEmailOrPhone.hidden)")
    }
    
    // Click main login btn and Pop out login form
    @IBAction func showLoginForm(sender: AnyObject) {
        
        var frame = self.logInForm.frame
        frame.origin.y = self.view.bounds.height - self.logInForm.frame.height
        
        
        UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: nil, animations: { () -> Void in
            
            
            self.logInForm.frame.origin.y = frame.origin.y
            
            NSLog("\(self.logInForm.frame.origin.y)")
            
            self.logInForm.backgroundColor = UIColor.blueColor()
            
            
            // look over this then delete
            //            self.logInForm.center.y = self.view.bounds.height - self.logInForm.frame.height
            
            
//            self.loginBtn.hidden = true
//            self.createAcctBtn.hidden = true
            
            
            }) { (Bool) -> Void in
                self.logInForm.frame = frame
                //self.logInForm.becomeFirstResponder()
        }
        
    }
    
    // Click cancel and Pop in login form
    @IBAction func loginCancel(sender: AnyObject) {
        
        UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: nil, animations: { () -> Void in
            
            self.logInForm.center.y = 2 * self.logInForm.frame.height
            self.loginBtn.hidden = false
            self.createAcctBtn.hidden = false
            
            }) { (Bool) -> Void in
                
        }
        
    }
    
    // Click create an acct within main login form
    @IBAction func needAcctBtn(sender: AnyObject) {
        loginCancel(self)
        showRegisterForm(self)
        
    }
    
    // Click main register btn and Pop out register form
    @IBAction func showRegisterForm(sender: AnyObject) {
        UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: nil, animations: { () -> Void in
            
            self.registerForm.center.y = self.registerForm.frame.height
            self.loginBtn.hidden = true
            self.createAcctBtn.hidden = true
            
            }) { (Bool) -> Void in
                
        }
    }
    
    // Click cancel and Pop in register form
    @IBAction func registerCancel(sender: AnyObject) {
        
        UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: nil, animations: { () -> Void in
            
            self.registerForm.center.y = 2 * self.registerForm.frame.height
            self.loginBtn.hidden = false
            self.createAcctBtn.hidden = false
            
            }) { (Bool) -> Void in
                
        }
    }
    
    // Click I already have an acct within main register form
    @IBAction func haveAcctBtn(sender: AnyObject) {
        registerCancel(self)
        showLoginForm(self)
        
    }
}
