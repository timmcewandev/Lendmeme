//
//  BorrowTableViewExtension.swift
//  Lendmeme
//
//  Created by Tim on 9/16/20.
//  Copyright © 2020 sudo. All rights reserved.
//

import UIKit
import CoreData


extension BorrowTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var newData: [ImageInfo] = []
        newData = searchText.isEmpty ? filteredData : filteredData.filter { $0.titleinfo!.lowercased().contains(searchText.lowercased()) }
        if newData.isEmpty == true || searchText == "" {
            imageInfo = filteredData
        } else {
            imageInfo = newData
        }
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        imageInfo = filteredData
        searchBar.resignFirstResponder()
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }

    
}
