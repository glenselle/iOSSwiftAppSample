//
//  User.swift
//  Gecko iOS
//

import Foundation
import Realm

class User: RLMObject {
    dynamic var _id = ""
    dynamic var name = ""
    dynamic var firstName = ""
    dynamic var lastName = ""
    dynamic var email = ""
    dynamic var phone = ""
    dynamic var username = ""
    dynamic var avatar = NSData(data: UIImagePNGRepresentation(UIImage(named: "avatar.png")))
    dynamic var created = NSDate()
    dynamic var lastUpdated = NSDate()
    
    override class func primaryKey() -> String {
        return "_id"
    }
    
    convenience init(json: NSDictionary) {
        self.init()
        
        // Set the id of the user
        if (json.objectForKey("_id") != nil) {
            self._id = json["_id"] as String
        }
        
        // Set the name of the user
        if (json.objectForKey("name") != nil) {
            let rawString = json["name"] as String
            self.name = rawString.gtm_stringByUnescapingFromHTML()
        }
        
        // Set the first name of the user
        if (json.objectForKey("firstName") != nil) {
            let rawString = json["firstName"] as String
            self.firstName = rawString.gtm_stringByUnescapingFromHTML()
        }
        
        // Set the last name of the user
        if (json.objectForKey("lastName") != nil) {
            let rawString = json["lastName"] as String
            self.lastName = rawString.gtm_stringByUnescapingFromHTML()
        }
        
        // Set the email of the user
        if (json.objectForKey("email") != nil) {
            let rawString = json["email"] as String
            self.email = rawString.gtm_stringByUnescapingFromHTML()
        }

        // Set the phone of the user
        if (json.objectForKey("phone") != nil) {
            self.phone = json["phone"] as String
        }
        
        // Set the username of the user
        if (json.objectForKey("username") != nil) {
            let rawString = json["username"] as String
            self.username = rawString.gtm_stringByUnescapingFromHTML()
        }
        
        // Set the avatar of the user as a UIImage on the user object
        if (json.objectForKey("avatar") != nil) {
            let avatarUrl = NSURL(string: json["avatar"] as String)
            var err: NSError?
            self.avatar = NSData.dataWithContentsOfURL(avatarUrl, options: NSDataReadingOptions.DataReadingMappedIfSafe, error: &err)
        }
        
        // Set the created date of the user
        if (json.objectForKey("created") != nil) {
            self.created = Utilities.isoToDate(json["created"] as String)
        }

        // Set the updated date of the user
        if (json.objectForKey("lastUpdated") != nil) {
            self.lastUpdated = Utilities.isoToDate(json["lastUpdated"] as String)
        }
    }
}