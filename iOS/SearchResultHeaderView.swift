//
//  SearchResultHeaderView.swift
//  Gecko iOS
//

import Foundation
import UIKit

class SearchResultHeaderView: UIView {
    
    var headerLabel: UILabel!
    
    override func drawRect(rect: CGRect) {
        headerLabel = UILabel(frame: CGRectMake(15, 3, rect.width, rect.height))
        headerLabel.textColor = geckoLightGreyText
        headerLabel.font = UIFont(name: "Helvetica", size: 12)
        headerLabel.text = "Search Results".uppercaseString
        
        self.addSubview(headerLabel)
    }


}