//
//  Utilities.swift
//  Gecko iOS
//

import Foundation
import Realm

class Utilities {
    
    class func isoToDate(iso: String) -> NSDate {
        let isoFormatter: NSDateFormatter = NSDateFormatter()
        
        isoFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        isoFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        return isoFormatter.dateFromString(iso)!
    }
    
    class func dateToMonthDayString(date: NSDate) -> String {
        let dateFormatter: NSDateFormatter = NSDateFormatter()
        
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.dateFormat = "MMMM dd"
        return dateFormatter.stringFromDate(date).uppercaseString
    }
    
    class func purgeRealm() {
        NSFileManager.defaultManager().removeItemAtPath(RLMRealm.defaultRealmPath(), error: nil)
    }
    
    class func delay(delay: Double, closure:()->()) {
        dispatch_after(dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
    }
    
    class func dictionaryToJsonString(dictionary: NSDictionary) -> String {
        return NSString(data: NSJSONSerialization.dataWithJSONObject(dictionary, options: NSJSONWritingOptions.allZeros, error: nil)!, encoding: NSUTF8StringEncoding)
    }
    
    class func squareImageFromImage(image: UIImage, scaledToSize: CGFloat) -> UIImage {
        var scaleTransform: CGAffineTransform!
        var origin: CGPoint!
        
        if image.size.width > image.size.height {
            let scaleRatio = scaledToSize / image.size.height
            scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio)
            
            origin = CGPointMake(-(image.size.width - image.size.height) / 2.0, 0)
        } else {
            let scaleRatio = scaledToSize / image.size.width
            scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio)
            
            origin = CGPointMake(0, -(image.size.height - image.size.width) / 2.0)
        }
        
        let size = CGSizeMake(scaledToSize, scaledToSize)
        
        if UIScreen.mainScreen().respondsToSelector("scale") {
            UIGraphicsBeginImageContextWithOptions(size, true, 0)
        } else {
            UIGraphicsBeginImageContext(size)
        }
        
        let context = UIGraphicsGetCurrentContext()
        CGContextConcatCTM(context, scaleTransform)
        
        image.drawAtPoint(origin)
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return finalImage
    }
    
    class func setCurrentUser(user: String) {
        NSUserDefaults.standardUserDefaults().setObject(user, forKey: "currentUser")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func getCurrentUser() -> String? {
        var currentUserString = NSUserDefaults.standardUserDefaults().objectForKey("currentUser") as? String
        
        if currentUserString == nil {
            return nil
        } else {
            return currentUserString!
        }
    }
    
    class func clearNSUserDefaults() {
        let appDomain = NSBundle.mainBundle().bundleIdentifier!
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain)
    }
}