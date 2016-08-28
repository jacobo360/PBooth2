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
    var connectedUnsubscribed: [String] = []
    var cameraSerials: [String] = []
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var tblView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set Up Design
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.whiteColor().CGColor
        
        //Set Up Connection
        reconnect()
    }
    
    func reconnect() {
        if let orderArray = defaults.objectForKey("cameraOrder") as? [String:Int] {
            connectedUnsubscribed = []
            cameraOrder = orderArray
            //Append only unsubscribed cameras
            for i in 0..<connectedCameras.count {
                let serial = cameraFunctionality().getSerials([connectedCameras[i]])[0]
                if !cameraOrder.keys.contains(serial) {
                    connectedUnsubscribed.append(serial)
                } else {
                }
            }
        } else {
            connectedUnsubscribed = cameraFunctionality().getSerials(connectedCameras)
        }
        tblView.reloadData()
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        
        return cameraOrder.keys.count + connectedUnsubscribed.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeViewWithIdentifier("Camera", owner: nil) as? NSTableCellView
        if tableColumn?.identifier == "Column0" {
            if row < cameraOrder.count {
                cell?.textField?.stringValue = Array(cameraOrder.keys)[row]
                return cell
            } else {
                cell?.textField?.stringValue = connectedUnsubscribed[row - cameraOrder.count]
                return cell
            }
            
        } else {
            if row < cameraOrder.count {
                print(row)
                print(String(Array(cameraOrder.values)[row]))
                cell?.textField?.delegate = self
                cell?.textField!.placeholderString = "Position Here"
                cell!.textField!.editable = true
                cell!.textField!.stringValue = String(Array(cameraOrder.values)[row])
                return cell
            } else {
                return cell
            }
            
        }
    }
    
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        print("textEndEditing")
        let tField = control as! NSTextField
        let i = tblView.rowForView(tField.superview as! NSTableCellView)
        
        if i >= 0 {
            if Int(tField.stringValue) != nil && Int(tField.stringValue) >= 0 {
                let camSerial = (tblView.viewAtColumn(0, row: i, makeIfNecessary: false)?.subviews[0] as! NSTextField).stringValue
                print(camSerial)
                subscribeCamera(camSerial, tField: tField)
                tblView.reloadData()
                return true
            } else {
                tField.stringValue = ""
                textFieldAlert("Isn't it obvious?", mess: "Please input a positive integer on the text field!")
                tblView.reloadData()
                return false
            }
        } else {return false}
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
                print(sorted)
                defaults.setObject(sorted, forKey: "cameraOrder")
                reconnect()
            }
        
        } else {
            let dict = [serial:Int(tField.stringValue)!]
            print(dict)
            defaults.setObject(dict, forKey: "cameraOrder")
            reconnect()
        }
        
    }
    
    func sortDict(d: [String:Int]) -> [String:Int] {
        var sorted: [String:Int] = [:]
        for (k,v) in (Array(d).sort {$1.1 < $0.1}) {
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
