//
//  LoginViewController.swift
//  Gecko iOS
//
//  Created by Glen Selle on 10/15/14.
//  Copyright (c) 2014 Zipline, inc. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var outerScrollView: UIScrollView!
    
    // Login form
    @IBOutlet weak var logInForm: UIView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var loginEmailOrPhone: UITextField!
    
    // Register Form
    @IBOutlet weak var registerForm: UIView!
    @IBOutlet weak var createAcctBtn: UIButton!
    @IBOutlet weak var registerEmailOrPhone: UITextField!
    @IBOutlet weak var registerFullName: UITextField!
    @IBOutlet weak var registerUsername: UITextField!
    
    // Bandaid
    @IBOutlet weak var registerFormhaveAcctBtn: UIButton!
    @IBOutlet weak var registerFormCancelBtn: UIButton!
    @IBOutlet weak var registerFormErrorText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register bandaid
        /*
            Buttons below form, just need to enlarge view vertically
        */
        registerFormhaveAcctBtn.hidden = true
        registerFormCancelBtn.hidden = true
        registerFormErrorText.hidden = true
        logInForm.hidden = true
        
        // Register a tap gesture to resign first responders on the two inputs
        let viewTapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        viewTapGesture.cancelsTouchesInView = false
        
        view.addGestureRecognizer(viewTapGesture)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // Register notifications to adjust the scrollview when inputs are selected
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardDidHideNotification, object: nil)
        
        let logoView = UIImageView(image: UIImage(named: "logo"))
        view.addSubview(logoView)
        
//        logoView.snp_makeConstraints { make in
//            make.edges.equalTo(superview).with.insets(padding)
//            return // this return is a fix for implicit returns in Swift and is only required for single line constraints
//        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        // Remove notifications to adjust the scrollview when inputs are deselected
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        NSLog("view appeared")
    }
    
    func keyboardWasShown(notification: NSNotification) {
        let info = notification.userInfo! as Dictionary
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue()
        
        let buttonOrigin = createAcctBtn.frame.origin
        let buttonHeight = createAcctBtn.frame.size.height
        var visibleRectangle = view.frame
        visibleRectangle.size.height -= keyboardFrame.height
        
        if CGRectContainsPoint(visibleRectangle, buttonOrigin) {
            let scrollPoint = CGPointMake(0, keyboardFrame.height)
            
            
            Utilities.delay(0.0) {
                
                UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: nil, animations: { () -> Void in
                    self.outerScrollView.contentOffset = scrollPoint
                }) { (Bool) -> Void in
                    self.outerScrollView.contentOffset = scrollPoint
                }
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        outerScrollView.setContentOffset(CGPointZero, animated: true)
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        
        // Resign first responder on inputs only if they are the current first responder
        if registerEmailOrPhone.isFirstResponder() {
            registerEmailOrPhone.resignFirstResponder()
        } else if registerFullName.isFirstResponder() {
            registerFullName.resignFirstResponder()
        } else if registerUsername.isFirstResponder() {
            registerUsername.resignFirstResponder()
        }
    }
    
    
    // Click main login btn and Pop out login form
    @IBAction func showLoginForm(sender: AnyObject) {
        
        var frame = self.logInForm.frame
        frame.origin.y = self.view.bounds.height - self.logInForm.frame.height
        
        
        UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: nil, animations: { () -> Void in
        
            
            self.logInForm.frame.origin.y = frame.origin.y
            self.logInForm.backgroundColor = UIColor.blueColor()
            
            self.loginBtn.hidden = true
            self.createAcctBtn.hidden = true

        
        }) { (Bool) -> Void in
            self.logInForm.frame = frame
            self.logInForm.becomeFirstResponder()
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
    
    func validateEmail(emailString: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluateWithObject(emailString)
    }
    
    @IBAction func signupBtn(sender: AnyObject) {
  
        var zipUserDictionary = [
            "name": registerFullName.text,
            "username": registerUsername.text
            ]
        
        if validateEmail(registerEmailOrPhone.text) {
            zipUserDictionary["email"] = registerEmailOrPhone.text
        } else {
            zipUserDictionary["phone"] = registerEmailOrPhone.text
        }
        
        NSLog("\(zipUserDictionary)")

        
        API.sharedInstance.POST("users", payload: zipUserDictionary, completionblock: {(error: NSError?, finalResponse: NSDictionary) -> () in
            
            let userId = finalResponse["user_id"] as String
            let token = finalResponse["access_token"] as String
            
            // Set the auth token with the userId
            if KeychainWrapper.setString(token, forKey: userId) {
                
                // Only if the token is saved successfully do we set the current user
                Utilities.setCurrentUser(userId)
                
                Utilities.delay(0.0, {
                    
                    // Segue into the main application UI on the main thread
                    self.performSegueWithIdentifier("login", sender: self)
                })
            }
        })
    }
    
    @IBAction func signInBttn(sender: AnyObject) {
        var frame = self.logInForm.frame
        frame.origin.y = self.view.bounds.height - self.logInForm.frame.height
        
        NSLog("hit the sign in button")
        
        UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: nil, animations: { () -> Void in
            
            self.view.bringSubviewToFront(self.logInForm)
            
            self.logInForm.frame.origin.y = frame.origin.y
            self.logInForm.backgroundColor = UIColor.blueColor()
            
            self.loginBtn.hidden = true
            self.createAcctBtn.hidden = true
            
            
            }) { (Bool) -> Void in
                self.logInForm.frame = frame
                self.logInForm.becomeFirstResponder()
        }
        
//        API.sharedInstance.GET("token", payload: zipUserDictionary, completionblock: {(error: NSError?, finalResponse: NSDictionary) -> () in
//            
//            let userId = finalResponse["user_id"] as String
//            let token = finalResponse["access_token"] as String
//            
//            // Set the auth token with the userId
//            if KeychainWrapper.setString(token, forKey: userId) {
//                
//                // Only if the token is saved successfully do we set the current user
//                Utilities.setCurrentUser(userId)
//                
//                Utilities.delay(0.0, {
//                    
//                    // Segue into the main application UI on the main thread
//                    self.performSegueWithIdentifier("login", sender: self)
//                })
//            }
//        })
    }
    
    // Textfield protocol implementation
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if registerEmailOrPhone.isFirstResponder() {
            registerFullName.becomeFirstResponder()
        } else if registerFullName.isFirstResponder() {
            registerUsername.becomeFirstResponder()
        } else if registerUsername.isFirstResponder() {
            registerUsername.resignFirstResponder()
            signupBtn(self)
        }
        
        return true
    }
}
