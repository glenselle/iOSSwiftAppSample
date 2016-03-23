//
//  ContactPickerLayout.swift
//  Gecko iOS
//

import Foundation
import UIKit
import Realm

class ContactPickerLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        let arr = super.layoutAttributesForElementsInRect(rect) as [UICollectionViewLayoutAttributes]
        
        return arr.map {
            atts in
            if atts.representedElementKind == nil {
                let ip = atts.indexPath
                atts.frame = self.layoutAttributesForItemAtIndexPath(ip).frame
            }
            return atts
        }
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        let atts = super.layoutAttributesForItemAtIndexPath(indexPath)
        
        if indexPath.item == 0 {
            return atts
        }
        
        if atts.frame.origin.x - 1 <= self.sectionInset.left {
            return atts
        }
        
        let ipPv = NSIndexPath(forItem:indexPath.item-1, inSection:indexPath.section)
        let fPv = self.layoutAttributesForItemAtIndexPath(ipPv).frame
        let rightPv = fPv.origin.x + fPv.size.width + self.minimumInteritemSpacing
        atts.frame.origin.x = rightPv
        return atts
    }
}