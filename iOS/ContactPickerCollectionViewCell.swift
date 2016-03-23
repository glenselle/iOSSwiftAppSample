//
//  ContactPickerCollectionViewCell.swift
//  Gecko iOS
//

import Foundation

class ContactPickerCollectionViewCell: UICollectionViewCell {
    
    var label: UILabel!
    var searchBox: UITextField!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.label = UILabel(frame: CGRectMake(0, 0, frame.width, frame.height))
        self.label.textAlignment = .Center
        self.label.textColor = geckoDarkBlue
        self.addSubview(self.label)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func turnOnSearchBox(frame: CGRect) {
        searchBox = UITextField(frame: frame)
        searchBox.placeholder = "Search for people"
        self.addSubview(searchBox)
    }
}