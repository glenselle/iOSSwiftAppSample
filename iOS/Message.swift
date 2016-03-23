//
//  Message.swift
//  Gecko iOS
//

import Foundation
import Realm

class Message: RLMObject {
    dynamic var _id = ""
    dynamic var type = ""
    dynamic var text = ""
    dynamic var hot = false
    dynamic var money = Bool()
    dynamic var transactions = RLMArray(objectClassName: Transaction.className())
    dynamic var author = User()
    dynamic var created = NSDate()
    dynamic var lastUpdated = NSDate()
    
    override class func primaryKey() -> String {
        return "_id"
    }
    
    convenience init(json: NSDictionary) {
        self.init()
        
        // Set the id of the message
        if (json.objectForKey("_id") != nil) {
            self._id = json["_id"] as String
        }
        
        // Set the type of the message
        if (json.objectForKey("type") != nil) {
            self.type = json["type"] as String
        }
        
        // Set the text of the message
        if (json.objectForKey("text") != nil) {
            let rawString = json["text"] as String
            self.text = rawString.gtm_stringByUnescapingFromHTML()
        }
        
        // Set whether or not the message contains money
        if (json.objectForKey("money") != nil) {
            self.money = json["money"] as Bool
        }
        
        // Set each transaction on the message
        var transactions = json["transactions"] as? [NSDictionary]
        if let transactionArray = transactions {
            for rawTransaction in transactionArray {
                var transaction = Transaction(json: rawTransaction)
                self.transactions.addObject(transaction)
            }
        }
        
        // Set the author of the message
        if json.objectForKey("author") != nil {
            
            if json.objectForKey("author")?.isKindOfClass(NSString) == true {
                var author = User()
                author._id = json["author"] as String
                self.author = author
            } else {
                self.author = User(json: json["author"] as NSDictionary)
            }
        }
        
        // Set the created date of the message
        if (json.objectForKey("created") != nil) {
            self.created = Utilities.isoToDate(json["created"] as String)
        }
        
        // Set the updated date of the message
        if (json.objectForKey("lastUpdated") != nil) {
            self.lastUpdated = Utilities.isoToDate(json["lastUpdated"] as String)
        }
    }
}