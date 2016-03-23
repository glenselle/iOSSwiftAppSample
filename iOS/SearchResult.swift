//
//  SearchResult.swift
//  Gecko iOS
//

import UIKit

class SearchResult: NSObject {
    var titleLabel = ""
    var subTitleLabel = ""
    var info: Dictionary<String, String>!
    
    convenience init(titleLabel: String, subTitleLabel: String, info: Dictionary<String, String>) {
        self.init()
        
        self.titleLabel = titleLabel
        self.subTitleLabel = subTitleLabel
        self.info = info
    }
}
