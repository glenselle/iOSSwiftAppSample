//
//  Account.swift
//  Gecko iOS
//

import Foundation
import Realm

class Account: RLMObject {
    dynamic var _id = ""
    dynamic var type = ""
    dynamic var name = ""
    dynamic var holder = ""
    dynamic var identifier = ""
    dynamic var secret = ""
    dynamic var lastFour = ""
    dynamic var address = Address()
    dynamic var created = NSDate()
    dynamic var lastUpdated = NSDate()
    
    override class func primaryKey() -> String {
        return "_id"
    }
    
    convenience init(json: NSDictionary) {
        self.init()
        
        // Set the id of the account
        if (json.objectForKey("_id") != nil) {
            self._id = json["_id"] as String
        }
        
        // Set the type of the account
        if (json.objectForKey("type") != nil) {
            self.type = json["type"] as String
        }
        
        // Set the name of the account
        if (json.objectForKey("name") != nil) {
            let rawString = json["name"] as String
            self.name = rawString.gtm_stringByUnescapingFromHTML()
        }
        
        // Set the data of the account
        if (json.objectForKey("holder") != nil) {
            let rawString = json["holder"] as String
            self.holder = rawString.gtm_stringByUnescapingFromHTML()
        }
        
        // Set the identifier of the account
        if (json.objectForKey("identifier") != nil) {
            self.identifier = json["identifier"] as String
        }
        
        // Set the secret for the account
        if (json.objectForKey("secret") != nil) {
            self.secret = json["secret"] as String
        }
        
        // Set the last four digits of the account number
        if (json.objectForKey("lastFour") != nil) {
            self.lastFour = json["lastFour"] as String
        }

        // Set the address of the account
        if (json.objectForKey("address") != nil) {
            self.address = Address(json: json["address"] as NSDictionary)
        }
        
        // Set the created date of the account
        if (json.objectForKey("created") != nil) {
            self.created = Utilities.isoToDate(json["created"] as String)
        }
        
        // Set the updated date of the account
        if (json.objectForKey("lastUpdated") != nil) {
            self.lastUpdated = Utilities.isoToDate(json["lastUpdated"] as String)
        }
    }
}