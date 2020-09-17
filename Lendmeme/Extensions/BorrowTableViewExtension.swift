//
//  BorrowTableViewExtension.swift
//  Lendmeme
//
//  Created by Tim on 9/16/20.
//  Copyright © 2020 sudo. All rights reserved.
//

import UIKit


extension BorrowTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var newData: [ImageInfo] = []
        newData = searchText.isEmpty ? filteredData : filteredData.filter { $0.titleinfo!.lowercased().contains(searchText.lowercased()) }
        if newData.isEmpty == true || searchText == "" {
            imageInfo = filteredData
        } else {
            imageInfo = newData
        }
        
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.text = ""
        imageInfo = filteredData
        searchBar.resignFirstResponder()
        
        tableView.reloadData()
    }

    
}
