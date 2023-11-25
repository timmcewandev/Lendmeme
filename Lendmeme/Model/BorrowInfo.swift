//
//  Copyright © 2018 McEwanTech. All rights reserved.
//

import Foundation
import UIKit

struct BorrowInfo {
    var topString: String?
    var bottomString: String?
    var titleString: String?
    var originalImage: UIImage
    var borrowImage: UIImage
    var hasBeenReturned = false
    var selectedDate: String?
    var reminderDate: Date
    var animationSeen: Bool = false
    var category: String?
    var timeHasExpired: Bool = false
}



