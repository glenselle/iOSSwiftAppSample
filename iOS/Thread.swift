//
//  Thread.swift
//  Gecko iOS
//

import Foundation
import Realm

class Thread: RLMObject {
    
    dynamic var _id = ""
    dynamic var name = ""
    dynamic var conversation = RLMArray(objectClassName: Message.className())
    dynamic var participants = RLMArray(objectClassName: User.className())
    dynamic var created = NSDate()
    dynamic var lastUpdated = NSDate()
    
    override class func primaryKey() -> String {
        return "_id"
    }
    
    convenience init(json: NSDictionary) {
        self.init()
        
        // Set the id of the thread
        if (json.objectForKey("_id") != nil) {
            self._id = json["_id"] as String
        }
        
        // Set the name of the thread
        if (json.objectForKey("name") != nil) {
            let rawString = json["name"] as String
            self.name = rawString.gtm_stringByUnescapingFromHTML()
        } else {
            self.name = "Untitled"
        }
        
        // Set the conversation of the thread
        var messages = json["conversation"] as? [NSDictionary]
        if let messageArray = messages {
            for rawMessage in messageArray {
                var message = Message(json: rawMessage)
                conversation.addObject(message)
            }
        }
        
        // Set the participants of the thread
        var users = json["participants"] as? [NSDictionary]
        if let userArray = users {
            for rawUser in userArray {
                var user = User(json: rawUser)
                participants.addObject(user)
            }
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