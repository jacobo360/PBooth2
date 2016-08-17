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
    @IBOutlet weak var profDeleteBtn: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 1...17 {
            shortMemoryOrder.append(i)
        }
        
        profileTbl.registerForDraggedTypes([NSGeneralPboard])
    }
    
    override func viewWillAppear() {
        setUpProfileMaker(myProfilesTbl.selectedRow)
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        let tabl = notification.object as! NSTableView
        if tabl == myProfilesTbl {
            let row = tabl.selectedRow
            //        shortMemoryName = table?.selection as! String
            //        print(shortMemoryName)
            setUpProfileMaker(row)
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if tableView == myProfilesTbl {
            if let data = defaults.objectForKey("profiles") as? NSData {
                let profiles = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [SessionProfile]
                return profiles.count
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
            let newProfile = SessionProfile(name: result, cameraCount: Int(numTextField.stringValue)!, cameraOrder: shortMemoryOrder)
            if let data = defaults.objectForKey("profiles") {
                var newArray = NSKeyedUnarchiver.unarchiveObjectWithData(data as! NSData) as! [SessionProfile]
                newArray.removeAtIndex(0)
                newArray.insert(newProfile, atIndex: 0)
                let newData = NSKeyedArchiver.archivedDataWithRootObject(newArray)
                defaults.setObject(newData, forKey: "profiles")
            } else {
                //This shouldn't happen because we created a new profile as a placeholder. If we got here, handle error.
                print("handle error")
            }
        }
        myProfilesTbl.reloadData()
        setUpProfileMaker(myProfilesTbl.selectedRow)
    }
    
    @IBAction func addNew(sender: AnyObject) {
        let newProfile = SessionProfile(name: "New Profile", cameraCount: 17, cameraOrder: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17])
        
        if let data = defaults.objectForKey("profiles") as? NSData {
            var newArray = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [SessionProfile]
            newArray.insert(newProfile, atIndex: 0)
            let newData = NSKeyedArchiver.archivedDataWithRootObject(newArray)
            defaults.setObject(newData, forKey: "profiles")
        } else {
            let data = NSKeyedArchiver.archivedDataWithRootObject([newProfile])
            defaults.setObject(data, forKey: "profiles")
        }
        myProfilesTbl.reloadData()
    }
    
    @IBAction func deleteProfile(sender: AnyObject) {
        if let data = defaults.objectForKey("profiles") as? NSData {
            var newArray = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [SessionProfile]
            newArray.removeAtIndex(myProfilesTbl.selectedRow)
            let newData = NSKeyedArchiver.archivedDataWithRootObject(newArray)
            defaults.setObject(newData, forKey: "profiles")
            myProfilesTbl.reloadData()
        }
    }
    
    func setNameModal(title: String, question: String, defaultValue: String) -> String {
        let msg = NSAlert()
        msg.addButtonWithTitle("Save")
        msg.addButtonWithTitle("Cancel")
        msg.messageText = title
        msg.informativeText = question
        msg.alertStyle = NSAlertStyle.InformationalAlertStyle
        
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
    
    func setUpProfileMaker(row: Int) {
        let pMakeArray: [NSView] = [profTblView, duplicateBtn, deleteBtn, numLbl, numTextField, addProfileBtn, profDeleteBtn]
        if myProfilesTbl.selectedRow == -1 {
            for pMake in pMakeArray {
                pMake.hidden = true
            }
        } else {
            if let data = defaults.objectForKey("profiles") as? NSData {
                var newArray = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [SessionProfile]
                let thisProfile = newArray[row]
                shortMemoryName = thisProfile.name
                shortMemoryOrder = thisProfile.cameraOrder
                numTextField.stringValue = String(thisProfile.cameraCount)
            }
            for pMake in pMakeArray {
                pMake.hidden = false
            }
            profileTbl.reloadData()
        }
    }
    
}
