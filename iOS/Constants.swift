//
//  Constants.swift
//  Gecko iOS
//

import Foundation

// Application user-agent
let appUserAgent = "iOS"
let MoneyRegex = "(\\$)([\\d,\\.]+)((?:(?:@[a-z]*))+)"

// The base endpoint (environment)
let apiBaseEndpoint = ""
//let apiBaseEndpoint = ""
let mockApiBaseEndpoint = ""

let tokenHeader = ""

// PubNub credentials
let pubnubPublishKey = ""
let pubnubSubscribeKey = ""

// This should be moved to the localized string file
let contactPickerPlaceholderText = "Search for people..."

// Colors
let FiretruckRed = UIColor(red:1, green:0.27, blue:0.33, alpha:1)
let Green = UIColor(red:0.38, green:0.78, blue:0.69, alpha:1)
let DarkBlue = UIColor(red:0.16, green:0.35, blue:0.41, alpha:1)
let LightGreyText = UIColor(red:0.69, green:0.69, blue:0.69, alpha:1)
let LightGrayEdges = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1)
let NavBarBg = UIColor(red:0.11, green:0.28, blue:0.33, alpha:1)

// This allows us to set the back button to an empty string so it only shows the back arrow
let emptyBackButtonFix = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Bordered, target: nil, action: nil)

// Keen io config
let keenProjectId = ""
let keenWriteKey = ""
let keenReadKey = ""

// Keen io - retrieve manages instance of keenclient
let client = KeenClient.sharedClient()
