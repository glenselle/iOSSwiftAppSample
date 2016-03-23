//
//  SearchResultsView.swift
//  Gecko iOS
//

import UIKit
import AddressBook
import Realm

// Custom protocl to pass control back to the view controler for a selected item
protocol SearchResultsDelegate {
    func searchResultSelected(result: SearchResult)
}

class SearchResultsView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    var delegate: SearchResultsDelegate?
    var searchData: Array<SearchResult> = []
    
    var addressBook: ABAddressBook!
    
    var searchResultTableView: UITableView!

    var zipMode: Bool = false
    
    override func drawRect(rect: CGRect) {
        searchResultTableView = UITableView(frame: rect)
        searchResultTableView.separatorColor = UIColor.clearColor()
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self
        self.addSubview(searchResultTableView)
    }
    
    func updateTableViewFrame(frame: CGRect) {
        NSLog("\(frame)")
        searchResultTableView.frame = CGRectMake(0, 0, frame.width, frame.height)
    }
    
    // This was a simple POC for getting a person's contacts that does actually work--can integrate where & when needed
    func getAddressBookData() {
        let stat = ABAddressBookGetAuthorizationStatus()
        
        switch stat {
        case .Denied, .Restricted:
            println("no access")
        case .Authorized, .NotDetermined:
            var err: Unmanaged<CFError>? = nil
            let adbk: ABAddressBook? = ABAddressBookCreateWithOptions(nil, &err).takeRetainedValue()
            if adbk == nil {
                println(err)
                return
            }
            ABAddressBookRequestAccessWithCompletion(adbk) {
                (granted:Bool, err:CFError!) in
                if granted {
                    self.addressBook = adbk
                    
                    func extractABItem(abItem: Unmanaged<AnyObject>!) -> String? {
                        if let ab = abItem {
                            return Unmanaged.fromOpaque(abItem.toOpaque()).takeUnretainedValue() as CFString as NSString
                        }
                        return nil
                    }
                    
                    func extractABItemRef(abItemRef: Unmanaged<ABMultiValueRef>!) -> ABMultiValueRef? {
                        if let ab = abItemRef {
                            return Unmanaged<NSObject>.fromOpaque(ab.toOpaque()).takeUnretainedValue()
                        }
                        return nil
                    }
                    
                    let people = ABAddressBookCopyArrayOfAllPeople(adbk).takeRetainedValue() as NSArray as [ABRecord]
                    for person in people {
                        
                        var personData = SearchResult()
                        var phoneString = ""
                        var emailString = ""
                        
                        // Get name
                        var nameString: String = ABRecordCopyCompositeName(person).takeRetainedValue() as NSString
                        personData.titleLabel = nameString
                        
                        // Get email(s)
                        let emailArray: ABMultiValueRef = extractABItemRef(ABRecordCopyValue(person, kABPersonEmailProperty))!
                        for (var j = 0; j < ABMultiValueGetCount(emailArray); ++j) {
                            var emailAdd = ABMultiValueCopyValueAtIndex(emailArray, j)
                            emailString = extractABItem(emailAdd)!
                        }
                        
                        // Get phone(s)
                        let phoneArray: ABMultiValueRef = extractABItemRef(ABRecordCopyValue(person, kABPersonPhoneProperty))!
                        for (var j = 0; j < ABMultiValueGetCount(phoneArray); ++j) {
                            var phoneAdd = ABMultiValueCopyValueAtIndex(phoneArray, j)
                            phoneString = extractABItem(phoneAdd)!
                        }
                        
                        // Show email if available, otherwise their phone number
                        if emailString != "" {
                            personData.subTitleLabel = emailString
                        } else if phoneString != "" {
                            personData.subTitleLabel = phoneString
                        }
                        
                        self.searchData.append(personData)
                    }
                    
                    // Run the reload table view on the main thread
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        // Fade in the table view cells
                        self.searchResultTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
                    }
                } else {
                    println(err)
                }
            }
        }
    }
    
    func refreshDataSource() {
        
        // Run the reload table view on the main thread
        dispatch_async(dispatch_get_main_queue()) {
            
            self.searchResultTableView.reloadData()
        }
    }
    
    // Tableview protocol implementations
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchData.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.searchResultSelected(searchData[indexPath.row])
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let identifier = "searchResultCell"
        
        if var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? SearchResultTableViewCell {
            if cell.isKindOfClass(SearchResultTableViewCell) {
                cell.reset(searchData[indexPath.row])
                return cell
            } else {
                var cell = SearchResultTableViewCell(style: .Default, reuseIdentifier: identifier, result: searchData[indexPath.row])
                return cell
            }
        } else {
            var cell = SearchResultTableViewCell(style: .Default, reuseIdentifier: identifier, result: searchData[indexPath.row])
            return cell
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "SEARCH RESULTS"
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = SearchResultHeaderView(frame: CGRectMake(5, 0, tableView.bounds.width, 20))
        headerView.backgroundColor = UIColor.whiteColor()
        return headerView
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
}