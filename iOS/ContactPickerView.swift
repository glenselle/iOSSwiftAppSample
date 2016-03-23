//
//  ContactPickerView.swift
//  Gecko iOS
//

import UIKit
import AddressBook
import Realm

// Custom protocl to pass control back to the view controler for a selected item
protocol ContactPickerDelegate {
    func didBeginSearching(text: String)
}

class ContactPickerView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {

    var delegate: ContactPickerDelegate?
    
    var contactData: Array<User> = []
    
    var editMode = false
    var compactMode = true
    
    var selectionState = Dictionary<Int, Bool>()
    
    let searchViewHeight = 40 as CGFloat
    let contactPickerHeight = 40 as CGFloat
    
    var containerView: UIView!
    var searchContainerView: UIView!
    var searchView: UITextField!
    var contactPickerContainerView: UIView!
    var contactPickerCollectionView: UICollectionView!
    var removePersonButton: UIButton!
    
    override func drawRect(rect: CGRect) {
        let layout: UICollectionViewFlowLayout = ContactPickerLayout()
        layout.minimumInteritemSpacing = 5
        
        if compactMode {
            containerView = UIView(frame: CGRectMake(0, -searchViewHeight, rect.width, searchViewHeight + contactPickerHeight))
        } else {
            containerView = UIView(frame: CGRectMake(0, 0, rect.width, searchViewHeight + contactPickerHeight))
        }
        
        searchContainerView = UIView(frame: CGRectMake(0, 0, rect.width, searchViewHeight))
        
        // Draw the bottom border on the container view
        let bottomSearchContainerViewBorder = CALayer()
        bottomSearchContainerViewBorder.borderColor = geckoLightGrayEdges.CGColor
        bottomSearchContainerViewBorder.borderWidth = 1
        bottomSearchContainerViewBorder.frame = CGRectMake(-1, -1, rect.width + 2, searchViewHeight + 1)
        searchContainerView.layer.addSublayer(bottomSearchContainerViewBorder)
        
        searchView = UITextField(frame: CGRectMake(10, 0, rect.width - 10, searchViewHeight))
        searchView.delegate = self
        searchView.placeholder = "Search for people..."
        searchContainerView.addSubview(searchView)
    
        contactPickerContainerView = UIView(frame: CGRectMake(0, searchViewHeight, rect.width, contactPickerHeight))
        
        // Draw the bottom border on the container view
        let bottomContactContainerViewBorder = CALayer()
        bottomContactContainerViewBorder.borderColor = geckoLightGrayEdges.CGColor
        bottomContactContainerViewBorder.borderWidth = 1
        bottomContactContainerViewBorder.frame = CGRectMake(-1, -1, rect.width + 2, contactPickerHeight + 1)
        contactPickerContainerView.layer.addSublayer(bottomContactContainerViewBorder)
        
        contactPickerCollectionView = UICollectionView(frame: CGRectMake(10, 0, rect.width, contactPickerHeight - 1), collectionViewLayout: layout)
        contactPickerCollectionView.backgroundColor = UIColor.whiteColor()
        contactPickerCollectionView.dataSource = self
        contactPickerCollectionView.delegate = self
        
        contactPickerCollectionView.registerClass(ContactPickerCollectionViewCell.self, forCellWithReuseIdentifier: "contact")
        
        // Populate the selection dictionary
        populateSelectionState()
        
        removePersonButton = UIButton(frame: CGRectMake(rect.width - 50, 5, 30, 30))
        removePersonButton.setImage(UIImage(named: "remove-person.png"), forState: UIControlState.Normal)
        removePersonButton.layer.opacity = 0
        contactPickerCollectionView.addSubview(removePersonButton)
        contactPickerContainerView.addSubview(contactPickerCollectionView)
        
        containerView.addSubview(searchContainerView)
        containerView.addSubview(contactPickerContainerView)
        self.addSubview(containerView)
    }
    
    convenience init(frame: CGRect, contacts: Array<User>, compact: Bool) {
        self.init(frame: frame)
        
        // Set the data for the collection view
        contactData = contacts
        
        // Set the compact mode setting
        compactMode = compact
    }
    
    func enableCompactMode(animated: Bool) {
        let frame = CGRectMake(0, -searchViewHeight, containerView.frame.width, searchViewHeight + contactPickerHeight)
        
        if animated {
            UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: nil, animations: { () -> Void in
                self.containerView.frame = frame
            }) { (Bool) -> Void in
                self.containerView.frame = frame
            }
        } else {
            self.containerView.frame = frame
        }
    }
    
    func disableCompactMode(animated: Bool) {
        let frame = CGRectMake(0, 0, containerView.frame.width, searchViewHeight + contactPickerHeight)
        
        if animated {
            UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: nil, animations: { () -> Void in
                self.containerView.frame = frame
            }) { (Bool) -> Void in
                self.containerView.frame = frame
            }
        } else {
            self.containerView.frame = frame
        }
    }
    
    func toggleCellSelectionState(cell: ContactPickerCollectionViewCell, indexPath: NSIndexPath) {
        if selectionState[indexPath.row] != nil && selectionState[indexPath.row] == true {
            cell.backgroundColor = UIColor.clearColor()
            cell.label.textColor = geckoDarkBlue
            
            // Reset the cell's selection state
            selectionState[indexPath.row] = false
        } else {
            cell.backgroundColor = geckoFiretruckRed
            cell.label.textColor = UIColor.whiteColor()
            
            // Reset the cell's selection state
            selectionState[indexPath.row] = true
        }
    }
    
    func populateSelectionState() {
        for var index = 0; index < contactData.count; index++ {
            selectionState[index] = false
        }
    }
    
    func refreshDataSource() {
        
        // Run the reload table view on the main thread
        dispatch_async(dispatch_get_main_queue()) {
            
            self.contactPickerCollectionView.reloadData()
        }
    }
    
    func removeSearchText() {
        searchView.text = ""
    }
    
    func showPersonButton(show: Bool) {
        if show {
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: nil, animations: { () -> Void in
                self.removePersonButton.layer.opacity = 1
            }) { (Bool) -> Void in
                self.removePersonButton.layer.opacity = 1
            }
        } else {
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: nil, animations: { () -> Void in
                self.removePersonButton.layer.opacity = 0
            }) { (Bool) -> Void in
                self.removePersonButton.layer.opacity = 0
            }
        }
    }
    
    func getSelectedUserIds() -> Array<String> {
        var returnArray = Array<String>()
        
        for contact in contactData {
            returnArray.append(contact._id)
        }
        
        return returnArray
    }
    
    // Textfield protocol implementation
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let textFieldString = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string) as NSString
        
        // Pass control back to the view controller to use the search text
        delegate?.didBeginSearching(textFieldString)
        
        return true
    }
    
    // CollectionView protocol implementations
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contactData.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let reuseIdentifier = "contact"
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as ContactPickerCollectionViewCell
        cell.label.text = contactData[indexPath.row].firstName + ","
        cell.layer.cornerRadius = 3
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let textWidth = (contactData[indexPath.row].firstName as NSString).boundingRectWithSize(CGSizeMake(200, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(16)], context: nil).width + 10
        return CGSize(width: textWidth, height: 30)
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 0, 0, 0)
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as ContactPickerCollectionViewCell
    
        // Toggle the cell's style
        toggleCellSelectionState(cell, indexPath: indexPath)
        
        var trueCount = 0
        var falseCount = 0
        
        for selectedState in selectionState.values {
            if selectedState == true {
                ++trueCount
            } else {
                ++falseCount
            }
        }
        
        if trueCount > 0 {
            showPersonButton(true)
        } else {
            showPersonButton(false)
        }
        
        trueCount = 0
        falseCount = 0
        
        // Set the edit mode boolean
        editMode = true
    }
}