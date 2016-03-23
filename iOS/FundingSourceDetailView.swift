//
//  FundingSourceDetailView.swift
//  Gecko iOS
//

import UIKit
import Foundation
import Realm

class FundingSourceDetailView: UIViewController {

    var account: Account!
    
    @IBOutlet weak var accountNameLabel: UILabel!
    @IBOutlet weak var lastFourDigitsLabel: UILabel!
    @IBOutlet weak var verificationDepositTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Prevent the title from showing next to the back button
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = emptyBackButtonFix
        
        // Set the title of the page to the name of the account
        self.navigationItem.title = account.name.capitalizedString
        
        // Set the name of the account
        accountNameLabel.text = account.name
        
        // Set the last four digits of the account secret
        lastFourDigitsLabel.text = account.lastFour
    }
    
    func setAccount(selectedAccount: Account) {
        
        account = selectedAccount
    }
    
    @IBAction func verificationButtonPressed(sender: AnyObject) {
        NSLog("\(verificationDepositTextField.text)")
    }
}
