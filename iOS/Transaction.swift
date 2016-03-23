//
//  Transaction.swift
//  Gecko iOS
//

import Foundation
import Realm

class Transaction: RLMObject {
    dynamic var _id = ""
    dynamic var fromUser = User()
    dynamic var toUser = User()
    dynamic var fromAccount = Account()
    dynamic var toAccount = Account()
    dynamic var amount = ""
    dynamic var currency = ""
    dynamic var arrivalDate = NSDate()
    dynamic var created = NSDate()
    dynamic var lastUpdated = NSDate()
    
    override class func primaryKey() -> String {
        return "_id"
    }
    
    convenience init(json: NSDictionary) {
        self.init()
        
        // Set the id of the transaction
        if (json.objectForKey("_id") != nil) {
            self._id = json["_id"] as String
        }
        
        // Set the origin user of the transaction
        if (json.objectForKey("fromUser") != nil) {
            self.fromUser = User(json: json["fromUser"] as NSDictionary)
        }
        
        // Set the receiving user of the transaction
        if (json.objectForKey("toUser") != nil) {
            self.toUser = User(json: json["toUser"] as NSDictionary)
        }
        
        // Set the origin account of the transaction
        if (json.objectForKey("fromAccount") != nil) {
            self.fromAccount = Account(json: json["fromAccount"] as NSDictionary)
        }
        
        // Set the receving account of the transaction
        if (json.objectForKey("toAccount") != nil) {
            self.toAccount = Account(json: json["toAccount"] as NSDictionary)
        }
        
        // Set the amount of the transaction
        if (json.objectForKey("amount") != nil) {
            self.amount = json["amount"] as String
        }
        
        // Set the currency of the transaction
        if (json.objectForKey("currency") != nil) {
            self.currency = json["currency"] as String
        }
        
        // Set the arrival date of the transaction
        if (json.objectForKey("created") != nil) {
            self.created = Utilities.isoToDate(json["created"] as String)
        }
        
        // Set the updated date of the transaction
        if (json.objectForKey("lastUpdated") != nil) {
            self.lastUpdated = Utilities.isoToDate(json["lastUpdated"] as String)
        }
    }
}