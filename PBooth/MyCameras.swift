//
//  MyCameras.swift
//  PBooth
//
//  Created by Jacobo Koenig on 8/16/16.
//  Copyright © 2016 Jacobo Koenig. All rights reserved.
//

import Cocoa

class MyCameras: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate {
    
    var cameraOrder: [String:Int] = [:]
    var connectedCameras: [EOSCamera] = []
    var cameraSerials: [String] = []
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var tblView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set Up Design
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.whiteColor().CGColor
        
        //Set Up Connection
        cameraSerials = cameraFunctionality().getSerials(connectedCameras)
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return cameraOrder.count + connectedCameras.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cameraCell = tableView.makeViewWithIdentifier("Camera", owner: self) as? NSTableCellView
        let positionCell = tableView.makeViewWithIdentifier("Position", owner: self) as? NSTableCellView
        
        if tableColumn == 0 {
            
            if row < cameraOrder.count {
                cameraCell?.textField?.stringValue = Array(cameraOrder.keys)[row]
                return cameraCell
            } else {
                cameraCell?.textField?.stringValue = cameraSerials[row - cameraOrder.count]
                return cameraCell
            }
            
        } else {
            
            if row < cameraOrder.count {
                positionCell?.textField?.stringValue = String(Array(cameraOrder.values)[row])
                return positionCell
            } else {
                return positionCell
            }
            
        }
    }
    
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        
        let tField = control as! NSTextField
        let i = tblView.rowForView(tField.superview as! NSTableCellView)
        
        if Int(tField.stringValue) != nil && Int(tField.stringValue) >= 0 {
            let camSerial = (tblView.viewAtColumn(0, row: i, makeIfNecessary: false)?.subviews[0] as! NSTextField).stringValue
            subscribeCamera(camSerial, tField: tField)
            tblView.reloadData()
            return true
        } else {
            tField.stringValue = ""
            textFieldAlert("Isn't it obvious?", mess: "Please input a positive integer on the text field!")
            tblView.reloadData()
            return false
        }
    }
    
    func subscribeCamera(serial: String, tField: NSTextField) {
        
        if let orderArray = defaults.objectForKey("cameraOrder") as? [String:Int] {
            
            cameraOrder = orderArray
            if cameraOrder.values.contains(Int(tField.stringValue)!) || cameraOrder.keys.contains(serial) {
                tField.stringValue = ""
                textFieldAlert("Error", mess: "Either the camera has already been subscribed, or the position is already taken")
            } else {
                cameraOrder[serial] = Int(tField.stringValue)!
                let sorted = sortDict(cameraOrder)
                defaults.setObject(sorted, forKey: "cameraOrder")
            }
        
        } else {
            let dict = [serial:Int(tField.stringValue)!]
            defaults.setObject(dict, forKey: "cameraOrder")
        }
        
    }
    
    func sortDict(d: [String:Int]) -> [String:Int] {
        var sorted: [String:Int] = [:]
        for (k,v) in (Array(d).sort {$0.1 < $1.1}) {
            sorted[k] = v
        }
        return sorted
    }
    
    func textFieldAlert(txt: String, mess: String) {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = txt
        myPopup.informativeText = mess
        myPopup.alertStyle = NSAlertStyle.WarningAlertStyle
        myPopup.addButtonWithTitle("OK")
        let res = myPopup.runModal()
        
        if res == NSAlertFirstButtonReturn {
        }
    }
    
}
