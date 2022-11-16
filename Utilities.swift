//
//  Utilities.swift
//  Lendmeme
//
//  Created by Tim McEwan on 10/4/22.
//  Copyright © 2022 sudo. All rights reserved.
//

import Foundation
import UIKit


struct BorrowTableUtilities {
    static let shared = BorrowTableUtilities()
    
    static func getCellForRowIndex(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, _ imageInfo: [[ImageInfo]]) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Cell.borrowTableViewCell, for: indexPath) as? BorrowTableViewCell
        let memeImages = imageInfo[indexPath.section][indexPath.row]
        cell?.imageCell = memeImages
        return cell ?? UITableViewCell()
    }
}
