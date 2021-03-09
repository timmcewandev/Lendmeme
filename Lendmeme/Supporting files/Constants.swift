//
//  Constants.swift
//  Lendmeme
//
//  Created by Tim McEwan on 3/8/21.
//  Copyright © 2021 sudo. All rights reserved.
//

import UIKit



struct Constants {
    
//    struct StoryboardIdentifier {
//        <#fields#>
//    }
    
    struct NameConstants {
        static let expiredText = "Expired"
    }
    
    struct CommandListText {
        static let markAsReturned = "Mark as returned"
        static let markAsNotReturned = "Mark as not returned"
        static let removeCalendar = "Remove calendar reminder"
        static let changeDateAndTime = "Change date & time"
        static let remindMe = "Remind me"
        static let delete = "Delete"
    }
    
    struct MesageText {
        
        static func getNameAndItemBorrowed(name: String, item: String) -> String {
            return "Hello \(name) 👋, I was wondering if you are done with the \(item)? Is there a time you could return it? Thanks 👏"
        }
        static let sendMessage = "Send text message"
        static let noNameOrItem = "Hello 👋, I was wondering if you are done with this item? Is there a time you could return it? Thanks 👏"
    }
    struct DateText {
        static let dateOnly = "MMM-dd-yyyy"
        static let dateAndTime = "MMM-dd-yyyy h:mm a"
    }
}
