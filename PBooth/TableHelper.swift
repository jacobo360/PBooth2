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
    
    var numbers: [String] = []
    var images:[NSImage] = []
    
    func getImages() {
        images = []
        for i in 50...66 {
            images.append(NSImage(named: "IMG_67\(i)")!)
            numbers.append(String(i-49))
        }
    }

    func tableViewSelectionDidChange(notification: NSNotification) {
        let table = notification.object
        let selection = table?.selectedRow
        imgView.image = images[selection!]
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        tableView.cell?.title = String(numbers[row])
        return numbers[row]
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        
        getImages()
        tableView.registerForDraggedTypes([NSGeneralPboard])
        
        return images.count
    }
    
    func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
        
        let data:NSData = NSKeyedArchiver.archivedDataWithRootObject(rowIndexes)
        let registeredTypes:[String] = [NSGeneralPboard]
        pboard.declareTypes(registeredTypes, owner: self)
        pboard.setData(data, forType: NSGeneralPboard)
        
        return true
    }
    
    func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        
        if dropOperation == .Above {
            return .Move
        }
        return .None
    }
    
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        
        let data: NSData = info.draggingPasteboard().dataForType(NSGeneralPboard)!
        let rowIndexes: NSIndexSet = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSIndexSet
        let value: NSImage = images[rowIndexes.firstIndex]
        images.removeAtIndex(rowIndexes.firstIndex)
        if (row > images.count)
        {
            images.insert(value, atIndex: row - 1)
        } else {
            images.insert(value, atIndex: row)
        }
        tableView.reloadData()
        return true
    }
    
}
