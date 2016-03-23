//
//  MasterViewController.swift
//  Gecko iOS
//

import Foundation
import AudioToolbox
import UIKit
import Realm

class MasterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var mainViewHeight: CGFloat!
    
    let threadEndpoint = "/threads"
    let userEndpoint = "/users/me"
    
    var token: String!
    var userId: String!
    
    var threads: Array<Thread> = []
    
    var threadTableView: UITableView!
    
    var currentThread: Int = 0
    
    let transitionManager = TransitionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Prevent the title from showing next to the back button
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = emptyBackButtonFix

        // Set the main view height
        mainViewHeight = self.view.frame.height - 64.0
        
        //let keychainWrapper = KeychainItemWrapper(identifier: userId, accessGroup: nil)
        
        // Configure PubNub & then connect
        PubNub.setConfiguration(PNConfiguration(forOrigin: "pubsub.pubnub.com", publishKey: pubnubPublishKey, subscribeKey: pubnubSubscribeKey, secretKey: nil))
        PubNub.connect()
        
        // Connect to the user channel and register a block to be fired on every new message
        let userChannel = PNChannel.channelWithName(Utilities.getCurrentUser(), shouldObservePresence: false) as PNChannel
        PubNub.subscribeOnChannel(userChannel)
        PNObservationCenter.defaultCenter().addMessageReceiveObserver(self, withBlock: { (message: PNMessage!) -> Void in
            let messageData = message.message as NSDictionary
            
            if messageData.objectForKey("type") as String == "thread" {
                let threadId = messageData.objectForKey("thread") as String
                
                let requestUrl = "threads/" + threadId
                
                API.sharedInstance.GET(requestUrl, completionblock: {(error: NSError, finalResponse: [NSDictionary]) -> () in
                    for rawThread in finalResponse {
                        var thread = Thread(json: rawThread)
                        
                        // Persist the threads to Realm
                        var realm = RLMRealm.defaultRealm()
                        realm.beginWriteTransaction()
                        realm.addOrUpdateObject(thread)
                        realm.commitWriteTransaction()
                        
                        self.refreshTableView()
                    }
                })
            } else if messageData.objectForKey("type") as String == "message" {
                
                // Update the thread's updatedAt property
                let threadId = messageData.objectForKey("thread") as String
                var updatedThread = Thread(forPrimaryKey: threadId)
                updatedThread.lastUpdated = NSDate.date()
                
                // Persist the threads to Realm
                var realm = RLMRealm.defaultRealm()
                realm.beginWriteTransaction()
                realm.addOrUpdateObject(updatedThread)
                realm.commitWriteTransaction()

                self.refreshTableView()
                
                // Add a new message event handler
                NSNotificationCenter.defaultCenter().postNotificationName("newPubNubMessage", object: nil, userInfo: messageData)
                
                // Vibrate when a new message is received
                AudioServicesPlaySystemSound(1352)
            }
        })
        
        // Add a new message event handler
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "addPubNubMessageToThread:", name:"newPubNubMessage", object: nil)
        
        Utilities.purgeRealm()
        
        // Fire off a request to get all the threads for a user
        loadThreads()
        loadAccounts()
        loadUser()
        drawTableView()
    }
    
    override func viewWillAppear(animated: Bool) {
        refreshTableView()
    }
    
    func loadThreads() {
        API.sharedInstance.GET("threads", completionblock: {(error: NSError, finalResponse: [NSDictionary]) -> () in
            for rawThread in finalResponse {
                var thread = Thread(json: rawThread)
                
                // Persist existing thread updates or add new threads to Realm if we've never added them before
                let realm = RLMRealm.defaultRealm()
                realm.beginWriteTransaction()
                realm.addOrUpdateObject(thread)
                realm.commitWriteTransaction()
            }
            
            // Run the reload table view on the main thread
            dispatch_async(dispatch_get_main_queue()) {
                
                // Get all of the threads from Realm sorted by their lastUpdated property
                for rawThread in Thread.allObjects().arraySortedByProperty("lastUpdated", ascending: true) {
                    let thread = rawThread as Thread
                    self.threads.append(thread)
                }
                
                // Fade in the table view cells
                self.threadTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
            }
        })
    }
    
    func loadAccounts() {
        API.sharedInstance.GET("accounts", completionblock: {(error: NSError, finalResponse: [NSDictionary]) -> () in
            for rawAccount in finalResponse {
                var account = Account(json: rawAccount)
                
                // Persist the threads to Realm
                var realm = RLMRealm.defaultRealm()
                realm.beginWriteTransaction()
                realm.addOrUpdateObject(account)
                realm.commitWriteTransaction()
            }
        })
    }
    
    func loadUser() {
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
    }
    
    func drawTableView() {
        let tableCellBorderPadding = 5 as CGFloat
        threadTableView = UITableView(frame: CGRectMake(0, 0, view.frame.size.width, mainViewHeight), style: .Grouped)
        threadTableView.backgroundColor = UIColor.whiteColor()
        threadTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        threadTableView.delegate = self
        threadTableView.dataSource = self
        
        view.addSubview(threadTableView)
    }
    
    func refreshTableView() {
        self.threads = []
        
        // Get all of the threads from Realm sorted by their lastUpdated property
        for rawThread in Thread.allObjects().arraySortedByProperty("lastUpdated", ascending: false) {
            let thread = rawThread as Thread
            self.threads.append(thread)
        }
        
        // Reload the tableview on the main thread
        Utilities.delay(0.0, {
            self.threadTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        })
    }
    
    func loadThread(thread: String) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "messageListView" {
            
            // Get destination view
            let destinationView = segue.destinationViewController as MessagingViewController
            
            // Pass the information to your destination view
            destinationView.setThread(self.threads[currentThread] as Thread)
        } else if segue.identifier == "newMessageListView" {
            
            // Get destination view
            let destinationView = segue.destinationViewController as MessagingViewController
            
            // Pass the information to your destination view
            destinationView.setThread(Thread())
        } else if segue.identifier == "profileSettingsSegue" {

            // this gets a reference to the screen that we're about to transition to
            let toViewController = segue.destinationViewController as UIViewController
            
            // instead of using the default transition animation, we'll ask
            // the segue to use our custom TransitionManager object to manage the transition animation
            toViewController.transitioningDelegate = self.transitionManager
        }
    }
    
    func addPubNubMessageToThread(notification: NSNotification) {
        if let info = notification.userInfo as? Dictionary<String, AnyObject> {
            
            var embeddedMessage = Message(json: (info["data"] as? NSDictionary)!)
            
            let threadId = (info["thread"]! as String)
            
            // Persist the message to Realm for future use
            var respectiveThread = Thread(forPrimaryKey: threadId)
            let realm = RLMRealm.defaultRealm()
            //realm.beginWriteTransaction()
            
            //realm.addObject(embeddedMessage)
            //respectiveThread.conversation.insertObject(embeddedMessage, atIndex: UInt(0))
            
            //realm.commitWriteTransaction()
            // 540729b543dd5d1868a42b5d
            // 540729b543dd5d1868a42b5d
            //self.threads = Thread.allObjects()
            
            // Fade in the table view cells
            //self.threadTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // Tableview protocol implementations
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return threads.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var identifier = "threadCell"
        
        let thread = self.threads[indexPath.row] as Thread
        
        if var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? ThreadTableViewCell {
            cell.reset(identifier, thread: thread)
            return cell
        } else {
            var cell = ThreadTableViewCell(style: .Default, reuseIdentifier: identifier, thread: thread)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currentThread = indexPath.row
        
        self.performSegueWithIdentifier("messageListView", sender: self)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01 as CGFloat
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20 as CGFloat
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100 as CGFloat
    }
}