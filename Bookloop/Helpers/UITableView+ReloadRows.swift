//
//  UITableView+ReloadRows.swift
//  Bookloop
//
//  Created by Charley Luckhardt on 9/13/16.
//  Copyright © 2016 Charles Luckhardt. All rights reserved.
//

import UIKit

extension UITableView {
    func reloadRowsInSection(_ section: Int, oldRowCount: Int, newRowCount: Int) {
        var oldRows: [Int] = []
        var newRows: [Int] = []
        
        if oldRowCount == 1 {
            oldRows = [0]
        } else if oldRowCount > 1 {
            oldRows = Array(0...oldRowCount-1)
        }
        if newRowCount == 1 {
            newRows = [0]
        } else if oldRowCount > 1 {
            newRows = Array(0...oldRowCount-1)
        }
    
        let oldIndexPaths = oldRows.map { row in IndexPath(row: row, section: section) }
        let newIndexPaths = newRows.map { row in IndexPath(row: row, section: section) }
            
        beginUpdates()
        deleteRows(at: oldIndexPaths, with: UITableViewRowAnimation.automatic)
        insertRows(at: newIndexPaths, with: UITableViewRowAnimation.automatic)
        endUpdates()
    }
}
