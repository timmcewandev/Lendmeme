//
//  Constants.swift
//  Lendmeme
//
//  Created by Tim McEwan on 3/8/21.
//  Copyright © 2021 sudo. All rights reserved.
//

import UIKit

struct Constants {
    struct CoreData {
        static let creationDate = "creationDate"
    }
    
    enum Categories: String, CaseIterable {
        case anything = "Anything"
        case books = "Books"
        case clothes = "Clothes"
        case movies = "Movies"
        case videoGames = "Video games"
        case tools = "Tools"
        
        static func gatherCategories() -> [String] {
            var categoryList: [String] = []
            for category in Categories.allCases {
                categoryList.append(category.rawValue)
            }
            return categoryList
        }
    }
    
    struct NotificationKey {
        static let key = "com.mcewantech.NotifyWhenTimeIsUP"
    }

    struct Segue {
        static let toStarterViewController = "starter"
        static let toEditorViewController = "toPhoto"
        static let toCalendarViewController = "toCalendar"
        static let borrowTableViewCell = "BorrowTableViewCell"
        static let pvController = "PVController"
    }
    
    struct Cell {
        static let borrowTableViewCell = "BorrowTableViewCell"
    }

    struct TextFieldNames {
        static let itemTitle = "add borrower's name"
        static let nameOfPersonBorrowing = "add item title"
        static let phoneNumberText = "add borrower's phone#"
    }
    struct NameConstants {
        static let expiredText = "Expired"
        static let statusNotReturned  = "Not returned"
        static let statusReturned = "Returned"
        static let selectedDate = "Selected Date"
    }
    
    struct CommandListText {
        static let markAsReturned = "Mark as returned"
        static let markAsNotReturned = "Mark as not returned"
        static let removeCalendar = "Remove calendar reminder"
        static let changeDateAndTime = "Change date & time"
        static let delete = "Delete"
        static let returnText = "Return"
        static let viewImage = "View image 🌁"
        static let cancel = "Cancel"
    }
    
    struct MesageText {
        
        static func getNameAndItemBorrowed(name: String, item: String) -> String {
            return "Hello \(name) 👋, I was wondering if you are done with my \(item)? Is there a time you could return it? Thanks"
        }
        
        static let sendMessage = "Send text message"
        static let noNameOrItem = "Hello 👋, I was wondering if you are done with this item? Is there a time you could return it? Thanks"
        static let scheduleText = ""
    }
    
    struct MessageAlerts {
        static func deleteAllMemedAlert() {
            let vc = BorrowTableViewController()
            let alert = UIAlertController(title: "⚠️ Warning ⚠️", message: "This will delete all items in returned section", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Nervermind", style: .default, handler: { _ in
                
            }))
            alert.addAction(UIAlertAction(title: "Delete all", style: .destructive, handler: { _ in
                vc.deleteAllMemes()
            }))
            vc.present(alert, animated: true, completion: nil)
        }
    }
    struct DateText {
        static let dateOnly = "MMM-dd-yyyy"
        static let dateAndTime = "MMM-dd-yyyy h:mm a"
    }
    struct SymbolsImage {
        static let checkMarkCircleFilled = "checkmark.circle.fill"
        static let calendarCircle = "calendar.circle"
    }
}
