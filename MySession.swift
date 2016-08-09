//
//  MySession.swift
//  PBooth
//
//  Created by Jacobo Koenig on 8/7/16.
//  Copyright © 2016 Jacobo Koenig. All rights reserved.
//

import Cocoa

class MySession: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var imgView: NSImageView!
    
    var numbers: [String] = []
    var images:[NSImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getImages()
        tableView.registerForDraggedTypes([NSGeneralPboard])
    }
    
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
        let sValue: String = numbers[rowIndexes.firstIndex]
        
        numbers.removeAtIndex(rowIndexes.firstIndex)
        images.removeAtIndex(rowIndexes.firstIndex)
        if (row > images.count)
        {
            numbers.insert(sValue, atIndex: row - 1)
            images.insert(value, atIndex: row - 1)
        } else {
            numbers.insert(sValue, atIndex: row)
            images.insert(value, atIndex: row)
        }
        tableView.reloadData()
        return true
    }

}
