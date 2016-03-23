//
//  CustomTableViewCell.swift
//  Gecko iOS
//

import Foundation
import UIKit

class TableViewCell: UITableViewCell {
    
    let darkBlue = UIColor(red:0.16, green:0.35, blue:0.41, alpha:1)
    var previousColor: UIColor? = UIColor.blackColor()
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        let normalScale = 1 as CGFloat
        let zoomedScale = 0.98 as CGFloat
        
        if(highlighted) {
            previousColor = self.textLabel?.textColor
            textLabel?.textColor = darkBlue
        } else {
            textLabel?.textColor = previousColor!
        }
    }
}