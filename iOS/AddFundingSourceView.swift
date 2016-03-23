//
//  FundingSourceView.swift
//  Gecko iOS
//

import Foundation
import UIKit
import Realm

class AddFundingSourceView: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UITextFieldDelegate, UIApplicationDelegate, SearchResultsDelegate {
    
    var checkingButton = UIButton.buttonWithType(.Custom) as UIButton
    var savingsButton = UIButton.buttonWithType(.Custom) as UIButton
    var backButton = UIButton.buttonWithType(.Custom) as UIButton
    
    var addressField = UITextField()
    var cityField = UITextField()
    var stateField = UITextField()
    var Field = UITextField()
    
    var addressTableView: UITableView!
    var addAddressView: UIView!
    
    let paleYellow = UIColor(red:1, green:0.95, blue:0.67, alpha:1)
    let peachRed = UIColor(red:1, green:0.27, blue:0.33, alpha:1)
    let paleTurqoise = UIColor(red:0.72, green:0.88, blue:0.84, alpha:1)
    let darkTurqoise = UIColor(red:0.38, green:0.78, blue:0.69, alpha:1)
    let silverLining = UIColor(red:0.83, green:0.83, blue:0.83, alpha:1)
    
    let addressArray = ["811 Greenbrier Dr.", "18852 Weston Ln."]
    
    @IBOutlet weak var searchBankField: UITextField!
    @IBOutlet weak var bankAccountNumberField: UITextField!
    @IBOutlet weak var saveChangesButton: UIButton!
    
    var account = Account()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prevent the title from showing next to the back button
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = emptyBackButtonFix
        
        // Register a tap gesture to resign first responders on the two inputs
        let viewTapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        viewTapGesture.cancelsTouchesInView = false
        
        // Draw the table view with a custom frame and table view style
        addressTableView = UITableView(frame: CGRectMake(0, 150, view.frame.size.width, 200), style: .Grouped)
        addAddressView = UIView(frame: CGRectMake(0, 150, view.frame.size.width, 200))
        
        // Register delegates
        viewTapGesture.delegate = self
        searchBankField.delegate = self
        bankAccountNumberField.delegate = self
        addressTableView.delegate = self
        
        // Add tags so we can identify the text fields later
        searchBankField.tag = 100
        bankAccountNumberField.tag = 101
        
        // Make the view controller the address table view's datasource
        addressTableView.dataSource = self
        
        // Add the gesture recodgnizer to the view
        view.addGestureRecognizer(viewTapGesture)

        // Draw the configured views
        drawAddressTableview()
        drawCheckingButton()
        drawSavingsButton()
        
        view.bringSubviewToFront(saveChangesButton)
    }
    
    func drawAddressTableview() {
        //addAddressView.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI), 1.0, 0.0, 0.0)
        drawAddAddressView()
        view.addSubview(addAddressView)
        
        addressTableView.scrollEnabled = false
        //addressTableView.reloadData()
        //view.addSubview(addressTableView)
    }
    
    func drawAddAddressView() {
        
        // Style the back button
        backButton.frame = CGRectMake(view.frame.size.width - 90.0, 20.0, 90.0, 50.0)
        backButton.backgroundColor = paleTurqoise
        backButton.setTitle("BACK", forState: .Normal)
        backButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        // Set the target/action for the button
        backButton.addTarget(self, action: "backButtonTouchUpInside", forControlEvents: .TouchUpInside)
        backButton.addTarget(self, action: "backButtonTouchDown", forControlEvents: .TouchDown)
        
        // Add the placeholders
        addressField.placeholder = "Street Address"
        cityField.placeholder = "City"
        stateField.placeholder = "State"
        Field.placeholder = "Zipcode"
        
        // Set the return key type
        addressField.returnKeyType = .Next
        cityField.returnKeyType = .Next
        stateField.returnKeyType = .Next
        Field.returnKeyType = .Done
        
        // Add tags so we can identify the text fields later
        addressField.tag = 102
        cityField.tag = 103
        stateField.tag = 104
        Field.tag = 105
        
        // Set the backgrounds
        addressField.backgroundColor = UIColor.whiteColor()
        cityField.backgroundColor = UIColor.whiteColor()
        stateField.backgroundColor = UIColor.whiteColor()
        Field.backgroundColor = UIColor.whiteColor()
        
        // Set the input field frames
        addressField.frame = CGRectMake(0.0, 70.0, view.frame.size.width, 50.0)
        cityField.frame = CGRectMake(0.0, 120.0, view.frame.size.width / 3, 50.0)
        stateField.frame = CGRectMake(view.frame.size.width / 3, 120.0, view.frame.size.width / 3, 50.0)
        Field.frame = CGRectMake((view.frame.size.width / 3) * 2, 120.0, view.frame.size.width / 3, 50.0)

        // Add all the inputs as subviews
        //addAddressView.addSubview(backButton)
        addAddressView.addSubview(addressField)
        addAddressView.addSubview(cityField)
        addAddressView.addSubview(stateField)
        addAddressView.addSubview(Field)
    }
    
    func backButtonTouchUpInside() {
        self.backButton.backgroundColor = self.paleTurqoise
        
        UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: nil, animations: { () -> Void in
            self.addressTableView.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI * 2), 1.0, 0.0, 0.0)
            self.addAddressView.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI), 1.0, 0.0, 0.0)
            
            self.addressTableView.alpha = 1
            self.addAddressView.alpha = 0
        }) { (Bool) -> Void in
            self.addressTableView.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI * 2), 1.0, 0.0, 0.0)
            self.addAddressView.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI), 1.0, 0.0, 0.0)
            
            self.view.bringSubviewToFront(self.addressTableView)
        }
    }
    
    func backButtonTouchDown() {
        backButton.backgroundColor = darkTurqoise
    }
    
    func drawCheckingButton() {
        let buttonWidth = view.frame.size.width / 2 + 3
        
        // Draw the checking button
        checkingButton.frame = CGRectMake(-1, 100, buttonWidth, 50)
        checkingButton.layer.borderWidth = 1
        checkingButton.layer.borderColor = silverLining.CGColor
        checkingButton.backgroundColor = UIColor.whiteColor()
        
        // Disabled state
        checkingButton.setTitle("Checking", forState:.Normal)
        checkingButton.setTitleColor(silverLining, forState:.Normal)
        
        // Selected & Highlighted state
        checkingButton.setTitleColor(UIColor.blackColor(), forState:.Selected)
        checkingButton.backgroundColor = paleYellow
        checkingButton.adjustsImageWhenHighlighted = false
        
        checkingButton.selected = true
        
        // Add the target action when the button is clicked
        checkingButton.addTarget(self, action: "checkingButtonTouchUpInside", forControlEvents: .TouchUpInside)
        
//        [self.view addConstraints:[NSLayoutConstraint
//            constraintsWithVisualFormat:@"V:|-[myView(>=748)]-|"
//            options:NSLayoutFormatDirectionLeadingToTrailing
//            metrics:nil
//            views:NSDictionaryOfVariableBindings(myView)]];
        
        // Set the default account type to checking
        account.type = "checking"
        
        view.addSubview(checkingButton)
    }
    
    func checkingButtonTouchUpInside() {
        savingsButton.backgroundColor = UIColor.whiteColor()
        checkingButton.backgroundColor = paleYellow
        
        // Swap selected states
        savingsButton.selected = false
        checkingButton.selected = true
        
        // Set the account model's type property
        account.type = "checking"
    }
    
    func drawSavingsButton() {
        let buttonWidth = view.frame.size.width / 2 + 1
        
        // Draw the savings button
        savingsButton.frame = CGRectMake(buttonWidth, 100, buttonWidth, 50)
        savingsButton.layer.borderWidth = 1
        savingsButton.layer.borderColor = silverLining.CGColor
        savingsButton.backgroundColor = UIColor.whiteColor()
        
        // Disabled state
        savingsButton.setTitle("Savings", forState:.Normal)
        savingsButton.setTitleColor(silverLining, forState:.Normal)
        
        // Selected state
        savingsButton.setTitleColor(UIColor.blackColor(), forState:.Selected)
        
        // Add the target action when the button is clicked
        savingsButton.addTarget(self, action: "savingsButtonSelected", forControlEvents: .TouchUpInside)
        
        view.addSubview(savingsButton)
    }
    
    func savingsButtonSelected() {
        checkingButton.backgroundColor = UIColor.whiteColor()
        savingsButton.backgroundColor = paleYellow
        
        // Swap selected states
        checkingButton.selected = false
        savingsButton.selected = true
        
        // Set the account model's type property
        account.type = "savings"
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        
        // Resign first responder on inputs only if they are the current first responder
        if searchBankField.isFirstResponder() {
            searchBankField.resignFirstResponder()
        } else if bankAccountNumberField.isFirstResponder() {
            bankAccountNumberField.resignFirstResponder()
        } else if addressField.isFirstResponder() {
            addressField.resignFirstResponder()
        } else if cityField.isFirstResponder() {
            cityField.resignFirstResponder()
        } else if stateField.isFirstResponder() {
            stateField.resignFirstResponder()
        } else if Field.isFirstResponder() {
            Field.resignFirstResponder()
        }
    }
    
    // Search result protocol implementations
    func searchResultSelected(result: SearchResult) {
        //let institution
    }
    
    // IBAction
    @IBAction func saveChangesTouchUpInside(sender: AnyObject) {
        //saveChangesButton.backgroundColor = darkTurqoise
        let firstName = "Glen"
        
        var address = Address()
        address.street = addressField.text
        address.city = cityField.text
        address.state = stateField.text
        address. = Field.text
        
        account.name = "\(firstName.capitalizedString)'s " + account.type.capitalizedString + " Account"
        account.holder = "Glen Selle"
        account.identifier = "898208347"
        account.secret = bankAccountNumberField.text
        account.address = address
        
        let accountDictionary = [
            "name": account.name,
            "type": account.type,
            "holder": account.holder,
            "identifier": account.identifier,
            "secret": account.secret,
            "address": [
                "street": address.street,
                "city": address.city,
                "state": address.state,
                "": address.
            ]
        ]
        
        API.sharedInstance.POST("accounts", payload: accountDictionary, completionblock: {(error: NSError?, finalResponse: NSDictionary) -> () in
            
            // The delay function executes the closure with GCD on the main thread so the UI is updated immediately--we don't need a delay
            Utilities.delay(0.0) {
                
                // Persist the newly returned thread to Realm
                let realm = RLMRealm.defaultRealm()
                realm.beginWriteTransaction()
                realm.addOrUpdateObject(Account(json: finalResponse))
                realm.commitWriteTransaction()
                
                self.navigationController?.popViewControllerAnimated(true)
                return
            }
        })
    }
    @IBAction func saveChangesTouchDown(sender: AnyObject) {
        saveChangesButton.backgroundColor = UIColor.blueColor()
    }
    
    // Textfield protcol implementations
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        
        // If the search field is selected, "next" goes to the account field
        if textField.tag == 100 {
            bankAccountNumberField.becomeFirstResponder()
        } else if textField.tag == 102 {
            addressField.becomeFirstResponder()
        } else if textField.tag == 103 {
            cityField.becomeFirstResponder()
        } else if textField.tag == 104 {
            stateField.becomeFirstResponder()
        } else if textField.tag == 105 {
            Field.becomeFirstResponder()
        }
        
        return true
    }
    
    // Tableview protocol implementations
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return addressArray.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let name = "addressCell"
        
        func renderCell(cell: UITableViewCell) {
            // If we're on the last cell, the text and styling should be slightly different
            if indexPath.row == addressArray.count {
                cell.textLabel?.text = "Add address"
                cell.textLabel?.textColor = silverLining
            } else {
                cell.textLabel?.text = addressArray[indexPath.row]
            }
            
            cell.selectionStyle = .None
        }
        
        if var cell = tableView.dequeueReusableCellWithIdentifier(name) as? TableViewCell {
            renderCell(cell)
            return cell
        } else {
            var cell = TableViewCell(style: .Default, reuseIdentifier: name)
            renderCell(cell)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) -> Void {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as TableViewCell!
        
        // Remove the cell selected state
        cell.selected = false
        
        if indexPath.row == addressArray.count {
            UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: nil, animations: { () -> Void in
                self.addressTableView.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI), 1.0, 0.0, 0.0)
                self.addAddressView.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI * 2), 1.0, 0.0, 0.0)
                
                self.addressTableView.alpha = 0
                self.addAddressView.alpha = 1
            }) { (Bool) -> Void in
                self.addressTableView.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI), 1.0, 0.0, 0.0)
                self.addAddressView.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI * 2), 1.0, 0.0, 0.0)
                
                self.view.bringSubviewToFront(self.addAddressView)
            }
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "ACCOUNT ADDRESS"
    }
}