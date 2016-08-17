//
//  MySession.swift
//  PBooth
//
//  Created by Jacobo Koenig on 8/7/16.
//  Copyright © 2016 Jacobo Koenig. All rights reserved.
//

import Cocoa

class MySession: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var imgView: NSImageView!
    @IBOutlet weak var selectedProfile: NSTextField!
    
    var numbers: [String] = []
    var images:[NSImage] = []
    var cameraOrder: [Int] = []
    var cameraCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set Up Design
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.whiteColor().CGColor

        getImages()
        tableView.registerForDraggedTypes([NSGeneralPboard])
        
        //GIFMaker().createGIF(with: images, frameDelay: 0.2)
        
        //Set Up Selected Profile
        restartProfile()
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
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        
        return images.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        tableView.cell?.title = String(numbers[row])
        return numbers[row]
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
        
        if rowIndexes.firstIndex < row {
            numbers.insert(sValue, atIndex: row)
            images.insert(value, atIndex: row)
            numbers.removeAtIndex(rowIndexes.firstIndex)
            images.removeAtIndex(rowIndexes.firstIndex)
        } else if rowIndexes.firstIndex > row {
            numbers.removeAtIndex(rowIndexes.firstIndex)
            images.removeAtIndex(rowIndexes.firstIndex)
            numbers.insert(sValue, atIndex: row)
            images.insert(value, atIndex: row)
        }
        
        tableView.reloadData()
        return true
    }

    @IBAction func duplicateBtn(sender: AnyObject) {
        if tableView.selectedRow != -1 {
            let row = tableView.selectedRow
            let value: NSImage = images[row]
            let sValue: String = numbers[row]
            numbers.insert(sValue, atIndex: row)
            images.insert(value, atIndex: row)
            tableView.reloadData()
        } else {
            selectionAlert("Duplicate")
        }
    }
    
    @IBAction func deleteBtn(sender: AnyObject) {
        //NOTE: Select previous row after duplication
        if tableView.selectedRow != -1 {
            let row = tableView.selectedRow
            numbers.removeAtIndex(row)
            images.removeAtIndex(row)
            tableView.reloadData()
        } else {
            selectionAlert("Delete")
        }
    }
    
    @IBAction func changeProfile(sender: AnyObject) {
        let a = NSAlert()
        a.messageText = "Change Default Profile"
        a.addButtonWithTitle("Done")
        a.addButtonWithTitle("Cancel")
        a.alertStyle = NSAlertStyle.WarningAlertStyle
        
        let dDown = NSPopUpButton(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        
        var profileList: [SessionProfile] = []
        
        if let data = defaults.objectForKey("profiles") as? NSData {
            profileList = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [SessionProfile]
            var nameList: [String] = []
            for prof in profileList {
                nameList.append(prof.name)
            }
            dDown.removeAllItems()
            dDown.addItemsWithTitles(nameList)
        } else {
        }
        
        a.accessoryView = dDown
        
        a.beginSheetModalForWindow(self.view.window!, completionHandler: { (modalResponse) -> Void in
            if modalResponse == NSAlertFirstButtonReturn {
                print(dDown.selectedItem)
                print(dDown.indexOfSelectedItem)
                if dDown.selectedItem != nil && dDown.indexOfSelectedItem != -1 {
                    let selection = profileList[dDown.indexOfSelectedItem]
                    let data = NSKeyedArchiver.archivedDataWithRootObject(selection)
                    self.defaults.setObject(data, forKey: "selectedProfile")
                    self.selectedProfile.stringValue = selection.name
                    self.restartProfile()
                } else {
                    self.defaults.removeObjectForKey("selectedProfile")
                    self.restartProfile()
                }
            }
        })
    }
    
    func selectionAlert(activity: String) {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = "Can't \(activity)"
        myPopup.informativeText = "Please select a row on the table to \(activity.lowercaseString) it"
        myPopup.alertStyle = NSAlertStyle.WarningAlertStyle
        myPopup.addButtonWithTitle("OK")
        let res = myPopup.runModal()
        
        if res == NSAlertFirstButtonReturn {
            //Should Restart Program-Handle Error
        }
    }
    
    func restartProfile() {
        if let data = defaults.objectForKey("selectedProfile") as? NSData {
            let profile = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! SessionProfile
            self.selectedProfile.stringValue = profile.name
            cameraOrder = profile.cameraOrder
            cameraCount = profile.cameraCount
            checkImagesAgainstProfile(profile)
        } else {
            //GO DEFAULT
            defaultProfile()
        }
    }
    
    func defaultProfile() {
        selectedProfile.stringValue = "Default"
        cameraOrder = []
        for i in 0..<images.count {
            cameraOrder.append(i)
        }
        cameraCount = cameraOrder.count
    }
    
    func checkImagesAgainstProfile(profile: SessionProfile) {
        if images.count != profile.cameraCount {
            defaultAlert("Image Count do not match the profile's Camera Count")
        }
    }
    
    func defaultAlert(text: String) {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = "Setting the Default Profile"
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlertStyle.WarningAlertStyle
        myPopup.addButtonWithTitle("OK")
        let res = myPopup.runModal()
        
        if res == NSAlertFirstButtonReturn {
            defaultProfile()
        }
    }
    
}
