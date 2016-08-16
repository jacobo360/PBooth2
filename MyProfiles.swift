//
//  MyProfiles.swift
//  PBooth
//
//  Created by Jacobo Koenig on 8/15/16.
//  Copyright © 2016 Jacobo Koenig. All rights reserved.
//

import Cocoa

class MyProfiles: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate {

    let defaults = NSUserDefaults.standardUserDefaults()
    var shortMemoryOrder: [Int] = []
    var shortMemoryName: String = "Untitled"
    
    @IBOutlet weak var myProfilesTbl: NSTableView!
    @IBOutlet weak var profileTbl: NSTableView!
    @IBOutlet weak var profTblView: NSScrollView!
    @IBOutlet weak var duplicateBtn: NSButton!
    @IBOutlet weak var deleteBtn: NSButton!
    @IBOutlet weak var numLbl: NSTextField!
    @IBOutlet weak var numTextField: NSTextField!
    @IBOutlet weak var addProfileBtn: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 1...17 {
            shortMemoryOrder.append(i)
        }
        
        profileTbl.registerForDraggedTypes([NSGeneralPboard])
    }
    
    override func viewWillAppear() {
        setUpProfileMaker()
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        let table = notification.object
        shortMemoryName = table?.selection as! String
        print(shortMemoryName)
        setUpProfileMaker()
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if tableView == myProfilesTbl {
            if let data = defaults.objectForKey("profiles") {
                let profiles = NSKeyedUnarchiver.unarchiveObjectWithData(data as! NSData) as? [SessionProfile]
                return profiles!.count
            }
            return 0
        } else if tableView == profileTbl {
            return shortMemoryOrder.count
        }
        return 0
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        if tableView == myProfilesTbl {
            if let data = defaults.objectForKey("profiles") {
                let profiles = NSKeyedUnarchiver.unarchiveObjectWithData(data as! NSData) as? [SessionProfile]
                return profiles![row].name
            }
            return "Error Getting Profile"
        } else if tableView == profileTbl {
            return String(shortMemoryOrder[row])
        }
        return "Error Getting Profile"
    }
    
    func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
        
        if tableView == profileTbl {
            let data:NSData = NSKeyedArchiver.archivedDataWithRootObject(rowIndexes)
            let registeredTypes:[String] = [NSGeneralPboard]
            pboard.declareTypes(registeredTypes, owner: self)
            pboard.setData(data, forType: NSGeneralPboard)
            
            return true
        } else {
            return false
        }
    }
    
    func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        
        if tableView == profileTbl && dropOperation == .Above {
            return .Move
            }
        return .None
    }
    
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        
        if tableView == profileTbl {
            let data: NSData = info.draggingPasteboard().dataForType(NSGeneralPboard)!
            let rowIndexes: NSIndexSet = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSIndexSet
            let value: Int = shortMemoryOrder[rowIndexes.firstIndex]
            
            if rowIndexes.firstIndex < row {
                shortMemoryOrder.insert(value, atIndex: row)
                shortMemoryOrder.removeAtIndex(rowIndexes.firstIndex)
            } else if rowIndexes.firstIndex > row {
                shortMemoryOrder.removeAtIndex(rowIndexes.firstIndex)
                shortMemoryOrder.insert(value, atIndex: row)
            }
            
            tableView.reloadData()
            return true
        } else {
            return false
        }
    }
    
    @IBAction func duplicateBtn(sender: AnyObject) {
        if profileTbl.selectedRow != -1 {
            let row = profileTbl.selectedRow
            let value: Int = shortMemoryOrder[row]
            shortMemoryOrder.insert(value, atIndex: row)
            profileTbl.reloadData()
        } else {
            selectionAlert("Duplicate")
        }
    }
    
    @IBAction func deleteBtn(sender: AnyObject) {
        //NOTE: Select previous row after duplication
        if profileTbl.selectedRow != -1 {
            let row = profileTbl.selectedRow
            shortMemoryOrder.removeAtIndex(row)
            profileTbl.reloadData()
        } else {
            selectionAlert("Delete")
        }
    }
    
    @IBAction func SaveProfile(sender: AnyObject) {
        let result: String = setNameModal("Save your Profile", question: "Please input your profile's name", defaultValue: shortMemoryName)
        if result != "" {
            let newProfile = SessionProfile()
            newProfile.name = result
            newProfile.cameraCount = shortMemoryOrder.count
            newProfile.cameraOrder = shortMemoryOrder
            if var profiles = defaults.arrayForKey("profiles") {
                profiles.insert(profiles, atIndex: 0)
                defaults.setObject(profiles, forKey: "profiles")
            } else {
                defaults.setObject([newProfile], forKey: "profiles")
            }
        }
    }
    
    @IBAction func addNew(sender: AnyObject) {
        let newProfile = SessionProfile()
        newProfile.name = "New Profile"
        newProfile.cameraCount = shortMemoryOrder.count
        newProfile.cameraOrder = shortMemoryOrder
        let data = NSKeyedArchiver.archivedDataWithRootObject(newProfile)
        
        if var profiles = defaults.arrayForKey("profiles") {
            profiles.insert(data, atIndex: 0)
            defaults.setObject(data, forKey: "profiles")
        } else {
            defaults.setObject([data], forKey: "profiles")
        }
        myProfilesTbl.reloadData()
    }
    
    func setUpProfileMaker() {
        let pMakeArray: [NSView] = [profTblView, duplicateBtn, deleteBtn, numLbl, numTextField, addProfileBtn]
        if myProfilesTbl.selectedRow == -1 {
            for pMake in pMakeArray {
                pMake.hidden = true
            }
        } else {
            for pMake in pMakeArray {
                pMake.hidden = false
            }
            profileTbl.reloadData()
        }
    }
    
    func setNameModal(title: String, question: String, defaultValue: String) -> String {
        let msg = NSAlert()
        msg.addButtonWithTitle("Save")
        msg.addButtonWithTitle("Cancel")
        msg.messageText = title
        msg.informativeText = question
        
        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        txt.stringValue = defaultValue
        
        msg.accessoryView = txt
        let response: NSModalResponse = msg.runModal()
        
        if (response == NSAlertFirstButtonReturn) {
            return txt.stringValue
        } else {
            return ""
        }
    }
    
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        
        shortMemoryOrder = []

        if Int(numTextField.stringValue) != nil && Int(numTextField.stringValue) >= 0 {
            let num = Int(numTextField.stringValue)
            for i in 1...num! {
                shortMemoryOrder.append(i)
            }
            profileTbl.reloadData()
            return true
        } else {
            textFieldAlert()
            profileTbl.reloadData()
            return true
        }
    }
    
    func textFieldAlert() {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = "Isn't it obvious?"
        myPopup.informativeText = "Please input a positive integer on the text field!"
        myPopup.alertStyle = NSAlertStyle.WarningAlertStyle
        myPopup.addButtonWithTitle("OK")
        let res = myPopup.runModal()
        
        if res == NSAlertFirstButtonReturn {
            numTextField.stringValue = "0"
        }
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
}
