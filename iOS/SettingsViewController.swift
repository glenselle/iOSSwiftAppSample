//
//  SettingsViewController.swift
//  Gecko iOS
// 

import Foundation
import UIKit
import Realm

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UITextFieldDelegate, UIApplicationDelegate, UIViewControllerTransitioningDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Container views
    var settingsTableView: UITableView!
    
    // Embedded Views
    var headerView: UIView!
    var avatarImageView: UIImageView!
    var fullnameTextFieldView: UITextField!
    var usernameTextField: UITextField!
    
    var accounts: Array<Account> = []
    
    let tableViewHeaderHeight = 40 as CGFloat
    let headerViewHeight = 120 as CGFloat
    
    // Selection ints
    var selectedAccount: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prevent the title from showing next to the back button
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = emptyBackButtonFix
        
        // Register a tap gesture to resign first responders on the two inputs
        let viewTapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        viewTapGesture.cancelsTouchesInView = false
        
        let mainViewHeight = self.view.frame.height - 64.0
        let mainViewWidth = self.view.frame.width
        
        settingsTableView = UITableView(frame: CGRectMake(0, 0, view.frame.width, mainViewHeight), style: .Grouped)
        settingsTableView.backgroundView = nil
        
        // Attach the gesture recognizer to the message list table view
        settingsTableView.addGestureRecognizer(viewTapGesture)
        
        // Register delegates
        viewTapGesture.delegate = self
        settingsTableView.delegate = self
        
        // Set the datasource for the message table view
        settingsTableView.dataSource = self
        
        let realmArray = Account.allObjects()
        for rawAccount in realmArray {
            let account = rawAccount as Account
            accounts.append(account)
        }
        
        // Add the sub views
        view.addSubview(settingsTableView)
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
    
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "setVerificationPattern" {
            
            // Get destination view
            let destinationView = segue.destinationViewController as PatternViewController
            
            // Pass the information to your destination view
            destinationView.setConfigurationMode(true)
        } else if segue.identifier == "fundingSourceDetailViewSegue" {
            
            // Get destination view
            let destinationView = segue.destinationViewController as FundingSourceDetailView
            
            // Pass the information to your destination view
            destinationView.setAccount(accounts[selectedAccount])
        }
    }
    
    func showPicturePicker(recognizer: UITapGestureRecognizer) {
        var imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // Image Picker protocol implementation
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        let resizedImage = Utilities.squareImageFromImage(image, scaledToSize: 400 as CGFloat)
        self.dismissViewControllerAnimated(true, completion: nil)
        
        API.sharedInstance.UPLOAD("user/avatar", file: UIImagePNGRepresentation(resizedImage)) { (error, finalResponse) -> () in
            Utilities.delay(0.0, {
                API.sharedInstance.GET("users/me", completionblock: {(error: NSError, finalResponse: [NSDictionary]) -> () in
                    for rawUser in finalResponse {
                        var user = User(json: rawUser)
                        
                        // Persist the threads to Realm
                        var realm = RLMRealm.defaultRealm()
                        realm.beginWriteTransaction()
                        realm.addOrUpdateObject(user)
                        realm.commitWriteTransaction()
                    }
                })
                self.avatarImageView.image = resizedImage
            })
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        NSLog("You canceled the picker")
    }
    
    // Tableview protocol implementation
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Variable type is inferred
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as? UITableViewCell
        if !(cell != nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL")
        }
        
        // Funding source section
        if indexPath.section == 1 {
            
            // If we're not on the last row of the accounts section we get the name of the account, otherwise we display static text
            if indexPath.row != accounts.count {
                cell!.textLabel?.text = accounts[indexPath.row].name.capitalizedString
                cell!.textLabel?.textColor = geckoDarkBlue
            } else {
                //BankAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bankCell" forIndexPath:indexPath];
                cell!.textLabel?.text = "Add new funding source"
                cell!.textLabel?.textColor = geckoLightGreyText
            }
        }
        
        // Private information section
        if indexPath.section == 2 {
            if indexPath.row == 0 {
                cell!.textLabel?.text = "Email"
            } else if indexPath.row == 1 {
                cell!.textLabel?.text = "Phone"
            } else if indexPath.row == 2 {
                cell!.textLabel?.text = "SSN"
            } else if indexPath.row == 3 {
                cell!.textLabel?.text = "Secret key pattern"
            } else if indexPath.row == 4 {
                cell!.textLabel?.text = "Password"
            }
        }
        
        // Settings section
        if indexPath.section == 3 {
            if indexPath.row == 0 {
                cell!.textLabel?.text = "Notifications"
            } else if indexPath.row == 1 {
                cell!.textLabel?.text = "Share on facebook"
            } else if indexPath.row == 2 {
                cell!.textLabel?.text = "Share on twitter"
            } else if indexPath.row == 3 {
                cell!.textLabel?.text = "Privacy & terms"
            }
        }
        
        // Report a problem section
        if indexPath.section == 4 {
            if indexPath.row == 0 {
                cell!.textLabel?.text = "General feedback"
            } else if indexPath.row == 1 {
                cell!.textLabel?.text = "Something isn't working"
            } else if indexPath.row == 2 {
                cell!.textLabel?.text = "Report abuse"
            }
        }
        
        // About section
        if indexPath.section == 5 {
            if indexPath.row == 0 {
                cell!.textLabel?.text = "About this version"
            } else if indexPath.row == 1 {
                cell!.textLabel?.text = "Log Out"
            }
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as UITableViewCell!
        
        if indexPath.section == 1 {
            if indexPath.row != accounts.count {
                selectedAccount = indexPath.row
                self.performSegueWithIdentifier("fundingSourceDetailViewSegue", sender: self)
            } else {
                self.performSegueWithIdentifier("addFundingSourceSegue", sender: self)
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 3 {
                self.performSegueWithIdentifier("setVerificationPattern", sender: self)
            }
        } else if indexPath.section == 3 {
            if indexPath.row == 3 {
                self.performSegueWithIdentifier("privacyTermsSegue", sender: self)
            }
        } else if indexPath.section == 4 {
            if indexPath.row == 0 {
                
                let config = UVConfig(site: "ziplinelabs.uservoice.com")
                
                if let userId = Utilities.getCurrentUser() {
                    let currentUser = User(forPrimaryKey: userId)
                    
                    config.identifyUserWithEmail(currentUser.email, name: currentUser.name, guid: currentUser._id)
                }
                
                // Set this up once when your application launches
                config.forumId = 270600
                
                // UserVoice Appearance Settings
                UVStyleSheet.instance().navigationBarBackgroundImage = UIImage(named: "navBarBg")
                UVStyleSheet.instance().navigationBarTintColor = UIColor.whiteColor()
                UVStyleSheet.instance().navigationBarTextColor = UIColor.whiteColor()
                
                // [config identifyUserWithEmail:@"email@example.com" name:@"User Name", guid:@"USER_ID");
                UserVoice.initialize(config)
                
                
                // Call this wherever you want to launch UserVoice
                //UserVoice.presentUserVoiceContactUsFormForParentViewController(self)
                UserVoice.presentUserVoiceInterfaceForParentViewController(self)
            }
        } else if indexPath.section == 5 {
            if indexPath.row == 1 {
                let keychainWrapper = KeychainItemWrapper(identifier: Utilities.getCurrentUser(), accessGroup: nil)
                keychainWrapper.resetKeychainItem()
                
                NSUserDefaults.standardUserDefaults().removeObjectForKey("currentUser")
                self.performSegueWithIdentifier("logout", sender: self)
                
                NSLog("Logged Out")
            }
        }
        
        // Remove the cell selected state
        cell.selected = false
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return headerViewHeight
        } else {
            return tableViewHeaderHeight
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableViewHeaderHeight
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            headerView = UIView(frame: CGRectMake(0, 0, view.frame.width, headerViewHeight))
            headerView.backgroundColor = UIColor.whiteColor()
            
            let singleFingerTap = UITapGestureRecognizer(target: self, action: "showPicturePicker:")
            
            avatarImageView = UIImageView(frame: CGRectMake(15, 15, 90, 90))
            
            avatarImageView.layer.cornerRadius = 45
            avatarImageView.layer.masksToBounds = true
            avatarImageView.backgroundColor = UIColor.blackColor()
            headerView.addSubview(avatarImageView)
            
            fullnameTextFieldView = UITextField(frame: CGRectMake(headerViewHeight, 15, view.frame.width - headerViewHeight, 45))
            headerView.addSubview(fullnameTextFieldView)
            
            usernameTextField = UITextField(frame: CGRectMake(headerViewHeight, 15 + 45, view.frame.width - headerViewHeight, 45))
            headerView.addSubview(usernameTextField)
            
            headerView.addGestureRecognizer(singleFingerTap)
            
            if let userId = Utilities.getCurrentUser() {
               let currentUser = User(forPrimaryKey: userId)
                
                avatarImageView.image = UIImage(data: currentUser.avatar)
                fullnameTextFieldView.text = currentUser.name
                usernameTextField.text = currentUser.username
            }
            
            return headerView
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return  "FUNDING SOURCES"
        } else if section == 2 {
            return "PRIVATE INFORMATION"
        } else if section == 3 {
            return "ZIPLINE SETTINGS"
        } else if section == 4 {
            return "REPORT A PROBLEM"
        } else if section == 5 {
            return "ABOUT ZIPLINE"
        } else {
            return ""
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else if section == 1 {
            return accounts.count + 1
        } else if section == 2 {
            return 5
        } else if section == 3 {
            return 4
        } else if section == 4 {
            return 3
        } else if section == 5 {
            return 2
        } else {
            return 1
        }
    }
}