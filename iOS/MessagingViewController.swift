//
//  MessagingViewController.swift
//  Gecko iOS
//

import Foundation
import AudioToolbox
import Realm
import UIKit

class MessagingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UITextFieldDelegate, UIApplicationDelegate, SearchResultsDelegate, ContactPickerDelegate {
    
    let moneyRegex = NSRegularExpression(pattern: geckoMoneyRegex, options: NSRegularExpressionOptions.CaseInsensitive, error: nil)
    
    var searchData: Array<SearchResult> = []
    
    var mainViewHeight: CGFloat!
    
    // Container views
    var editableTitleHeader: UITextField!
    var contactPickerView: ContactPickerView!
    var messageTableView: UITableView!
    var messageInputView: UIView!
    var searchResultsView: SearchResultsView!
    var contactPickerTextView: UITextView!
    
    // Embedded detail views
    var textView: UITextField!
    var sendButton: UIButton!
    
    var thread: Thread!
    var participants: Array<User> = []
    var conversation: Array<Message> = []
    var composedMessage: Message!
    
    let contactPickerHeight = 40.0 as CGFloat
    let inputViewHeight = 60.0 as CGFloat
    let inputActionButtonWidth = 60 as CGFloat
    
    var incomingMessage: Message!
    
    let masterChannel = PNChannel.channelWithName("master", shouldObservePresence: false) as PNChannel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let searchString = "Here's $5,897@kirk@ria@lou and then also $3@broque kkk asdfkj Ya, und hier ist CHF4,38@yohannes or also FR3,98@lou and then INR5@john or USD4.23@luzter" as NSString
        
        // Prevent the title from showing next to the back button
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = emptyBackButtonFix
        
        // Set the main view height
        mainViewHeight = self.view.frame.height - 64.0
        
        // Register a tap gesture to resign first responders on the two inputs
        let viewTapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        viewTapGesture.cancelsTouchesInView = false
        
        let mainViewWidth = self.view.frame.width
        
        messageTableView = UITableView(frame: CGRectMake(0, contactPickerHeight, view.frame.width, mainViewHeight - contactPickerHeight - inputViewHeight), style: .Grouped)
        messageTableView.backgroundView = nil;
        messageTableView.backgroundColor = UIColor.whiteColor()
        messageTableView.separatorStyle = .None
        
        // Attach the gesture recognizer to the message list table view
        messageTableView.addGestureRecognizer(viewTapGesture)
        
        // Only show the messages table view if there are any messages
        if conversation.count == 0 {
            
            // Show the editable title on new threads
            renderEditableTitle()
            
            // Render the contact picker in non-compact mode
            renderContactPicker(false)
            
            searchResultsView = SearchResultsView(frame: CGRectMake(0, contactPickerHeight * 2, view.frame.width, mainViewHeight - contactPickerHeight - inputViewHeight))
            
            // Tell the search results view to get the address book data
            //searchResultsView.getAddressBookData()
            
            messageTableView.hidden = true
            searchResultsView.hidden = true
        } else {
            
            // Render the contact picker in non-compact mode
            renderContactPicker(true)
            
            searchResultsView = SearchResultsView(frame: CGRectMake(0, contactPickerHeight, view.frame.width, mainViewHeight - contactPickerHeight - inputViewHeight))
            
            // We pass the search result data to the view
            searchResultsView.searchData = searchData
            
            messageTableView.hidden = false
            searchResultsView.hidden = true
        }
        
        searchResultsView.delegate = self
        
        textView = UITextField()
        
        // Register delegates
        viewTapGesture.delegate = self
        messageTableView.delegate = self
        textView.delegate = self
        
        // Add tags so we can identify the textfields later
        textView.tag = 100
        
        // Set the datasource for the message table view
        messageTableView.dataSource = self
        
        // Set the title bar to the title of the thread
        self.navigationItem.title = thread.name.capitalizedString
        
        // Add the sub views
        view.addSubview(messageTableView)
        view.addSubview(searchResultsView)
        renderInputView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add a new message event handler
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "addPubNubMessageToThread:", name:"newPubNubMessage", object: nil)
        
        // Add two keyboard event handlers
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func unwindPatternVerification(segue: UIStoryboardSegue) {
        
        // If there is an incoming message, add it to the table view & then set incomingMessage to nil
        if incomingMessage != nil {
            resetInputView()
            
            addAndPublishMessageToThread(incomingMessage)
            
            incomingMessage = nil
        }
    }
    
    func setIncomingMessage(message: Message) {
        incomingMessage = message
    }
    
    func setThread(selectedThread: Thread) {
        
        thread = selectedThread
        
        // Since we're given a RLMArray we must iterate and add the messages to a generic array
        for rawMessage in thread.conversation {
            let message = rawMessage as Message
            conversation.append(message)
        }
        
        // Since we're given a RLMArray we must iterate and add the participants to a generic array
        for rawUser in thread.participants {
            var user = rawUser as User
            let infoDictionary = [
                "username": user.username
            ]
            searchData.append(SearchResult(titleLabel: user.name.capitalizedString, subTitleLabel: "@" + user.username, info: infoDictionary))
            participants.append(user)
        }
    }
    
    func renderContactPicker(compact: Bool) {
        contactPickerView = ContactPickerView(frame: CGRectMake(0, 0, view.frame.width, 80), contacts: participants, compact: compact)
        contactPickerView.backgroundColor = UIColor.whiteColor()
        contactPickerView.delegate = self
        
        view.addSubview(contactPickerView)
    }
    
    func renderEditableTitle() {
        editableTitleHeader = UITextField(frame: CGRectMake(0, 0, 150, 30))
        editableTitleHeader.backgroundColor = UIColor(red:0.16, green:0.35, blue:0.41, alpha:0.5)
        
        editableTitleHeader.layer.cornerRadius = 5
        editableTitleHeader.text = "Untitled Zip"
        editableTitleHeader.font = UIFont.boldSystemFontOfSize(19)
        editableTitleHeader.textColor = UIColor.whiteColor()
        editableTitleHeader.textAlignment = .Center
        self.navigationItem.titleView = editableTitleHeader
    }
    
    func renderInputView() {
        messageInputView = UIView()
        messageInputView.backgroundColor = UIColor.whiteColor()
        
        messageInputView.tag = 108
        
        // Draw the top border/edge on the input
        let topBorder = CALayer()
        topBorder.borderColor = geckoLightGrayEdges.CGColor
        topBorder.borderWidth = 1
        topBorder.frame = CGRectMake(-1, -1, view.layer.frame.width + 2, view.layer.frame.height)
        messageInputView.layer.borderColor = UIColor.whiteColor().CGColor
        messageInputView.layer.borderWidth = 1
        messageInputView.layer.addSublayer(topBorder)
        messageInputView.frame = CGRectMake(0, mainViewHeight - inputViewHeight, view.frame.width, inputViewHeight)
        
        let textfieldBackgroundView = UIView()
        textfieldBackgroundView.frame = CGRectMake(10, 10, view.layer.frame.width - inputActionButtonWidth - 30, messageInputView.layer.frame.height - 20)
        textfieldBackgroundView.layer.backgroundColor = UIColor.whiteColor().CGColor
        textfieldBackgroundView.layer.borderColor = geckoLightGrayEdges.CGColor
        textfieldBackgroundView.layer.cornerRadius = 5
        textfieldBackgroundView.layer.borderWidth = 1
        textfieldBackgroundView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight
        textfieldBackgroundView.tag = 105
        
        // Draw the text input view
        textView.frame = CGRectMake(5, 0, textfieldBackgroundView.frame.width - 10, textfieldBackgroundView.frame.height)
        textView.textColor = UIColor.blackColor()
        textView.backgroundColor = UIColor.clearColor()
        //textView.textContainer.lineFragmentPadding = 0
        textView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        //textView.inputAccessoryView = inputAccessoryForFindingKeyboard;
        textView.placeholder = "Type a message..."
        //textView. setTextContainerInset:UIEdgeInsetsZero];
        textView.font = UIFont(name: "HelveticaNeue", size:16)
        
        textfieldBackgroundView.addSubview(textView)
        
        // Draw the send button
        sendButton = UIButton(frame: CGRectMake(view.layer.frame.width - inputActionButtonWidth - 10, 10, inputActionButtonWidth, 40))
        sendButton.layer.cornerRadius = 5
        sendButton.backgroundColor = UIColor(red:226.0/255, green:226.0/255, blue:226.0/255, alpha:1)
        sendButton.autoresizingMask = UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleTopMargin
        sendButton.setTitleColor(UIColor(red:174.0/255, green:174.0/255, blue:174.0/255, alpha:1), forState:.Normal)
        sendButton.addTarget(self, action: "sendTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        sendButton.setTitle("SEND", forState:.Normal)
        sendButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size:13)
        
        
//        self.mediaButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        self.mediaButton.contentMode = UIViewContentModeScaleAspectFit;
//        self.mediaButton.frame = CGRectMake(0, 0, 50, 24);
//        self.mediaButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
//        self.mediaButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
//        
//        [self.mediaButton addTarget:self action:@selector(mediaTapped:) forControlEvents:UIControlEventTouchUpInside];
//        [self.mediaButton setImage:[UIImage imageNamed:@"attachment.png"] forState:UIControlStateNormal];
        
        // We don't support attachments yet, so we don't show this
        //[self addSubview:self.mediaButton]; 
        
        messageInputView.addSubview(textfieldBackgroundView)
        messageInputView.addSubview(sendButton)
        view.addSubview(messageInputView)
    }
    
    func resetInputView() {
        
        // Remove the text from the input & reset its styling
        textView.text = ""
        setButtonColorState("empty")
    }
    
    func sendTapped(sender: AnyObject) {
        let messageText = textView.text as NSString
        
        if conversation.count == 0 {
            
            var newThread = [
                "name": editableTitleHeader.text,
                "conversation": [
                    "type": "text",
                    "money": false,
                    "text": textView.text
                ],
                "participants": contactPickerView.getSelectedUserIds()
            ]
            
            API.sharedInstance.POST("threads", payload: newThread, completionblock: { (error, finalResponse) -> () in
                let newThread = Thread(json: finalResponse)
                
                // Persist the newly created thread
                let realm = RLMRealm.defaultRealm()
                realm.beginWriteTransaction()
                realm.addObject(newThread)
                realm.commitWriteTransaction()
            })
        }
        
        // Only proceed if we have text entered
        if messageText.length > 0 {
            
            // Create a message object
            composedMessage = Message()
            composedMessage.text = messageText
            
            if let userId = Utilities.getCurrentUser() {
                composedMessage.author = User()
                composedMessage.author._id = userId
            }
            
            let results = moneyRegex.matchesInString(messageText, options: nil, range: NSMakeRange(0, messageText.length)) as [NSTextCheckingResult]
            
            if results.count > 0 {
                composedMessage.money = true
                composedMessage.hot = true
                
                moneyRegex.enumerateMatchesInString(messageText, options: nil, range: NSMakeRange(0, messageText.length)) { (result: NSTextCheckingResult!,_,_) in
                    
                    let usernameArray = (messageText.substringWithRange(result.rangeAtIndex(3)) as NSString).substringFromIndex(1).componentsSeparatedByString("@")
                    
                    for username in usernameArray {
                        
                        let userResults = self.participants.filter { $0.username == username }
                        
                        var transaction = Transaction()
                        transaction.toUser = userResults[0]
                        
                        transaction.currency = messageText.substringWithRange(result.rangeAtIndex(1))
                        transaction.amount = messageText.substringWithRange(result.rangeAtIndex(2))
                        
                        self.composedMessage.transactions.addObject(transaction)
                    }
                }
                
                // Resign first responder on the textview so the keyboard is dismissed
                textView.resignFirstResponder()
                
                // Hide the search results in case they are still showing
                searchResultsView.hidden = true
                
                self.performSegueWithIdentifier("patternVerification", sender: self)
            } else {
                addAndPublishMessageToThread(composedMessage)
                resetInputView()
            }
        }
    }
    
    func addPubNubMessageToThread(notification: NSNotification) {
        if let info = notification.userInfo as? Dictionary<String, AnyObject> {
            
            var embeddedMessage = Message(json: (info["data"] as? NSDictionary)!)
            
            if ((info["thread"]! as String) == (thread._id as String)) {
                
                // Convert the json into a message object and add to the thread
                addMessageToThread(embeddedMessage)
            }
        }
    }
    
    func addAndPublishMessageToThread(message: Message) {
        
        if let userId = Utilities.getCurrentUser() {
            let token = KeychainWrapper.stringForKey(userId)!
            
            composedMessage.author = User()
            composedMessage.author._id = userId
        
            // First construct a JSON message sent via PubNub
            let messageDictionary = [
                "type": "message",
                "thread": thread._id,
                "token": token,
                "data": [
                    "author": message.author._id,
                    "text": message.text,
                    "money": message.money
                ]
            ]
        
            // Convert the dictionary into a JSON string
            let stringThing = Utilities.dictionaryToJsonString(messageDictionary) as String

            // Publish the message via PubNub
            PubNub.sendMessage(stringThing, toChannel: masterChannel)
            
            // Add the message to the thread
            addMessageToThread(message)
        }
    }
    
    func addMessageToThread(message: Message) {
        
//        // Persist the message to Realm for future use
//        let realm = RLMRealm.defaultRealm()
//        realm.beginWriteTransaction()
//        var currentThread = Thread(forPrimaryKey: thread._id)
//        currentThread.conversation.insertObject(message, atIndex: UInt(0))
//        realm.commitWriteTransaction()
        
        // Insert the object into the tableview's datasource array
        conversation.insert(message, atIndex: 0)
        
        // We have to get the conversation count after it has been updated with the latest message
        let lastRow = conversation.count - 1 as Int
        
        // Instruct the tableview to re-run cellForRowAtIndexPath (giving it the last row)
        messageTableView.insertRowsAtIndexPaths([NSIndexPath(forRow: lastRow, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
        
        // Scroll to the bottom so we see the new message
        messageTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: lastRow, inSection: 0), atScrollPosition: .Bottom, animated: true)
    }
    
    func getCurrentMessage(row: Int) -> Message {
        return conversation[conversation.count - row - 1] as Message
    }
    
    func handleTap(recognizer: UITapGestureRecognizer) {

        if textView.isFirstResponder() {
            textView.resignFirstResponder()
        }
    }
    
    func setButtonColorState(state: String) {
        if state == "empty" {
            sendButton.backgroundColor = UIColor(red:226.0/255, green:226.0/255, blue:226.0/255, alpha:1)
            sendButton.setTitleColor(UIColor(red:174.0/255, green:174.0/255, blue:174.0/255, alpha:1), forState:.Normal)
            sendButton.setTitle("SEND", forState: .Normal)
        } else if state == "filled" {
            sendButton.backgroundColor = geckoGreen
            sendButton.setTitleColor(UIColor.whiteColor(), forState:.Normal)
            sendButton.setTitle("SEND", forState: .Normal)
        } else if state == "money" {
            sendButton.backgroundColor = geckoFiretruckRed
            sendButton.setTitleColor(UIColor.whiteColor(), forState:.Normal)
            sendButton.setTitle("ZIP", forState: .Normal)
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let mainViewHeight = self.view.frame.height - 64.0
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            
            if messageInputView.frame.origin.y != mainViewHeight - inputViewHeight {
                moveInputViewUp(true, size: keyboardSize)
            } else {
                moveInputViewUp(false, size: keyboardSize)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let mainViewHeight = self.view.frame.height - 64.0
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            
            if messageInputView.frame.origin.y != mainViewHeight - inputViewHeight {
                moveInputViewUp(false, size: keyboardSize)
            } else {
                moveInputViewUp(true, size: keyboardSize)
            }
        }
    }
    
    func moveInputViewUp(movedUp: Bool, size: CGRect) {
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.3)
        //UIView.setAnimationCurve(curve)
        
        if movedUp {
            messageTableView.frame.size.height -= size.height
            messageInputView.frame.origin.y -= size.height
        } else {
            messageTableView.frame.size.height += size.height
            messageInputView.frame.origin.y += size.height
        }
        
        UIView.commitAnimations()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "patternVerification" {
            
            // Get destination view
            let destinationView = segue.destinationViewController as PatternViewController
            
            // Pass the information to your destination view
            destinationView.setMessage(composedMessage)
        }
    }
    
    func updateSearchResultsViewHeight() {
        let newFrame = CGRectMake(0, searchResultsView.frame.origin.y, searchResultsView.frame.width, messageInputView.frame.origin.y - searchResultsView.frame.origin.y)
        searchResultsView.frame = newFrame
        searchResultsView.updateTableViewFrame(newFrame)
    }
    
    // Search field protocol implementations
    func didBeginSearching(text: String) {
        
        let searchString = "search?q=" + text
        
        if text != "" {
            
            // First resize then show the search results after you start typing
            updateSearchResultsViewHeight()
            searchResultsView.hidden = false
            
            API.sharedInstance.GET(searchString, completionblock: {(error: NSError, finalResponse: [NSDictionary]) -> () in
                
                self.searchResultsView.searchData = []
                
                for rawUser in finalResponse {
                    var person = SearchResult()
                    
                    person.titleLabel = rawUser["name"] as String
                    person.subTitleLabel = "@" + (rawUser["username"] as String)
                    person.info = ["_id": rawUser["_id"] as String]
                    
                    self.searchResultsView.searchData.append(person)
                }
                
                // Once all the data has been inserted we refresh the data source
                self.searchResultsView.refreshDataSource()
            })
        } else {
            
            // Hide the results if you haven't entered anything
            searchResultsView.hidden = true
        }
    }
    
    // Search result protocol implementations
    func searchResultSelected(result: SearchResult) {
        
        if searchResultsView.zipMode {
            
            // Insert the username into the input field
            textView.text = textView.text + result.info["username"]! + " "
            
            // Hide the results after you select the first person
            searchResultsView.hidden = true
        } else {
            
            var user = User()
            user._id = result.info["_id"]! as String
            user.firstName = split(result.titleLabel) {$0 == " "}[0]
            user.username = result.subTitleLabel
            
            // Add the new user object to the contact picker and also the participant array
            contactPickerView.contactData.append(user)
            participants.append(user)
            
            // Remove the text from the search input field
            contactPickerView.removeSearchText()
            
            // Refresh the datasource
            contactPickerView.refreshDataSource()
            
            // Hide the results after you select the first person
            searchResultsView.hidden = true
        }
    }
    
    // Textfield protcol implementations
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        
        // If the text input field is selected, "done" closes the keyboard
        if textField.tag == 100 {
            textView.resignFirstResponder()
        }
        
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let textFieldString = (textField.text as NSString).stringByReplacingCharactersInRange(range, withString: string) as NSString
        let moneyMessage = moneyRegex.numberOfMatchesInString(textFieldString, options: nil, range: NSMakeRange(0, textFieldString.length))
        
        if textFieldString.length == 0 {
            searchResultsView.hidden = true
            searchResultsView.zipMode = false
            setButtonColorState("empty")
        } else if moneyMessage > 0 {
            updateSearchResultsViewHeight()
            searchResultsView.hidden = false
            searchResultsView.zipMode = true
            searchResultsView.searchResultTableView.reloadData()
            setButtonColorState("money")
        } else {
            searchResultsView.hidden = true
            searchResultsView.zipMode = false
            setButtonColorState("filled")
        }
        
        return true
    }
    
    // Tableview protocol implementations
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversation.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let userCell = "userCell"
        let userMoneyCell = "userMoneyCell"
        let participantCell = "participantCell"
        let participantMoneyCell = "participantMoneyCell"
        var identifier = ""
        
        let currentMessage = getCurrentMessage(indexPath.row)
        
        // Determine the identifier we need for the message
        if let userId = Utilities.getCurrentUser() {
            if currentMessage.author._id == userId && currentMessage.money == false {
                identifier = userCell
            } else if currentMessage.author._id == userId && currentMessage.money == true {
                identifier = userMoneyCell
            } else if currentMessage.author._id != userId && currentMessage.money == false {
                identifier = participantCell
            } else if currentMessage.author._id != userId && currentMessage.money == true {
                identifier = participantMoneyCell
            }
        }
        
        if var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? MessageTableViewCell {
            if cell.isKindOfClass(MessageTableViewCell) {
                cell.reset(identifier, message: currentMessage)
                return cell
            } else {
                var cell = MessageTableViewCell(style: .Default, reuseIdentifier: identifier, message: currentMessage)
                return cell
            }
        } else {
            var cell = MessageTableViewCell(style: .Default, reuseIdentifier: identifier, message: currentMessage)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let message = getCurrentMessage(indexPath.row)
        
        return (message.text as NSString).boundingRectWithSize(CGSizeMake(200, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(15)], context: nil).height + 40
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let message = getCurrentMessage(indexPath.row)
        
        return (message.text as NSString).boundingRectWithSize(CGSizeMake(200, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(15)], context: nil).height + 40
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
}