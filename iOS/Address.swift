//
//  Address.swift
//  Gecko iOS
//

import Foundation
import Realm

class Address: RLMObject {
    dynamic var _id = ""
    dynamic var street = ""
    dynamic var city = ""
    dynamic var state = ""
    dynamic var zip = ""
    dynamic var country = ""
    dynamic var created = NSDate()
    dynamic var lastUpdated = NSDate()
    
    override class func primaryKey() -> String {
        return "_id"
    }
    
    convenience init(json: NSDictionary) {
        self.init()
        
        // Set the id of the address
        if (json.objectForKey("_id") != nil) {
            self._id = json["_id"] as String
        }
        
        // Set the street of the address
        if (json.objectForKey("street") != nil) {
            let rawString = json["street"] as String
            self.street = rawString.gtm_stringByUnescapingFromHTML()
        }
        
        // Set the city of the address
        if (json.objectForKey("city") != nil) {
            let rawString = json["city"] as String
            self.city = rawString.gtm_stringByUnescapingFromHTML()
        }
        
        // Set the state of the address
        if (json.objectForKey("state") != nil) {
            self.state = json["state"] as String
        }
        
        // Set the zip of the address
        if (json.objectForKey("zip") != nil) {
            self.zip = json["zip"] as String
        }
        
        // Set the country of the address
        if (json.objectForKey("country") != nil) {
            let rawString = json["country"] as String
            self.country = rawString.gtm_stringByUnescapingFromHTML()
        }
        
        // Set the created date of the address
        if (json.objectForKey("created") != nil) {
            self.created = Utilities.isoToDate(json["created"] as String)
        }
        
        // Set the updated date of the address
        if (json.objectForKey("lastUpdated") != nil) {
            self.lastUpdated = Utilities.isoToDate(json["lastUpdated"] as String)
        }
    }
}