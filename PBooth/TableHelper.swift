//
//  TableHelper.swift
//  PBooth
//
//  Created by Jacobo Koenig on 8/8/16.
//  Copyright © 2016 Jacobo Koenig. All rights reserved.
//

import Cocoa

class TableHelper: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var imgView: NSImageView!
    
    let numbers:[AnyObject] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]
    var images:[NSImage] = []
    
    func getImages() {
        for i in 50...66 {
            images.append(NSImage(named: "IMG_67\(i)")!)
        }
    }

    func tableViewSelectionDidChange(notification: NSNotification) {
        let table = notification.object
        let selection = table?.selectedRow
        imgView.image = images[selection!]
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        tableView.cell?.title = String(row)
        
        if row == numbers.count - 1 {
            getImages()
        }
        
        return numbers[row]
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return numbers.count
    }
    
}
