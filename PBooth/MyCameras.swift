//
//  MyCameras.swift
//  PBooth
//
//  Created by Jacobo Koenig on 8/16/16.
//  Copyright © 2016 Jacobo Koenig. All rights reserved.
//

import Cocoa

extension Dictionary where Value: Comparable {
    var valueKeySorted: [(Key, Value)] {
        return sort{ $0.1 > $1.1 }.sort{ String($0.0) < String($1.0) }
    }
//    // or sorting as suggested by Just Another Coder without using map
//    var valueKeySorted2: [(Key, Value)] {
//        return sort{ if $0.1 != $1.1 { return $0.1 > $1.1 } else { return String($0.0) < String($1.0) } }
//    }
}

class MyCameras: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate {
    
    var cameraOrder: [String:String] = [:]
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
        
//        cameraOrder["1"] = "123512"
//        cameraOrder["2"] = "1231232"
//        cameraOrder["3"] = "112512"
//        cameraOrder["4"] = "1212081"
//        defaults.setObject(cameraOrder, forKey: "cameraOrder")
        
        //Set Up Connection
        reconnect()
    }
    
    func reconnect() {
        if let orderArray = defaults.objectForKey("cameraOrder") as? [String:String] {
            connectedUnsubscribed = []
            cameraOrder = orderArray
            //Append only unsubscribed cameras
            for i in 0..<connectedCameras.count {
                let serial = cameraFunctionality().getSerials([connectedCameras[i]])[0]
                if !cameraOrder.values.contains(serial) {
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
                cell?.textField?.stringValue = Array(cameraOrder.values)[row]
                return cell
            } else {
                cell?.textField?.stringValue = connectedUnsubscribed[row - cameraOrder.count]
                return cell
            }
            
        } else {
            if row < cameraOrder.count {
                cell?.textField?.delegate = self
                cell?.textField!.placeholderString = "Position Here"
                cell!.textField!.editable = true
                cell!.textField!.stringValue = String(Array(cameraOrder.keys)[row])
                return cell
            } else {
                cell?.textField?.delegate = self
                cell?.textField!.placeholderString = "Position Here"
                cell!.textField!.editable = true
                //careful with this one.. might affect subscribed cameras
                cell!.textField!.stringValue = ""
                return cell
            }
            
        }
    }
    
    func control(control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        let tField = control as! NSTextField
        let i = tblView.rowForView(tField.superview as! NSTableCellView)
        
        if i >= 0 {
            if Int(tField.stringValue) != nil && Int(tField.stringValue) > 0 {
                let thisCam = (tblView.viewAtColumn(1, row: i, makeIfNecessary: false)?.subviews[0] as! NSTextField).stringValue
                let camSerial = (tblView.viewAtColumn(0, row: i, makeIfNecessary: false)?.subviews[0] as! NSTextField).stringValue
                
                //If camera exists, erase previous and input new)
                if var orderArray = defaults.objectForKey("cameraOrder") as? [String:String] {
                    if orderArray.values.contains(camSerial) {
                        
                        //remove all keys with value camSerial
                        for key in (orderArray as NSDictionary).allKeysForObject(camSerial) {
                            orderArray.removeValueForKey(key as! String)
                        }
                        
                        defaults.setObject(orderArray, forKey: "cameraOrder")
                        tblView.reloadData()
                    }
                }
                
                subscribeCamera(camSerial, tField: tField)
                tblView.reloadData()
                return true
            } else if tField.stringValue == "0" {
                if var orderArray = defaults.objectForKey("cameraOrder") as? [String:String] {
                    if Array(orderArray.keys)[i] != nil {
                        textFieldAlert("Camera Unsubscribed", mess: "You have unsubscribed camera \(Array(orderArray.values)[i])")
                        orderArray.removeValueForKey(Array(orderArray.keys)[i])
                        defaults.setObject(orderArray, forKey: "cameraOrder")
                    }
                }
                reconnect()
                return false
            } else {
                tField.stringValue = ""
                textFieldAlert("Isn't it obvious?", mess: "Please input a positive integer on the text field!")
                tblView.reloadData()
                return false
            }
        } else {return false}
    }
    
    func subscribeCamera(serial: String, tField: NSTextField) {
        
        if let orderArray = defaults.objectForKey("cameraOrder") as? [String:String] {
            cameraOrder = orderArray
            if cameraOrder.keys.contains(tField.stringValue) {
                tField.stringValue = ""
                textFieldAlert("Error", mess: "The position is already taken")
            } else {
                cameraOrder[tField.stringValue] = serial
                defaults.setObject(cameraOrder, forKey: "cameraOrder")
                reconnect()
            }
        
        } else {
            let dict = [tField.stringValue:serial]
            defaults.setObject(dict, forKey: "cameraOrder")
            reconnect()
        }
        
    }
    
    func textFieldAlert(txt: String, mess: String) {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = txt
        myPopup.informativeText = mess
        myPopup.alertStyle = NSAlertStyle.Warning
        myPopup.addButtonWithTitle("OK")
        let res = myPopup.runModal()
        
        if res == NSAlertFirstButtonReturn {
        }
    }
    
    @IBAction func deleteBtn(sender: AnyObject) {
        if defaults.objectForKey("cameraOrder") != nil && tblView.selectedRow != -1 {
            var orderArray = defaults.objectForKey("cameraOrder") as! [String:String]
            if tblView.selectedRow < orderArray.count {
                let tField = tblView.viewAtColumn(1, row: tblView.selectedRow, makeIfNecessary: false)!.viewWithTag(9) as! NSTextField
                orderArray.removeValueForKey(tField.stringValue)
                defaults.setObject(orderArray, forKey: "cameraOrder")
                tblView.reloadData()
            }
        }
    }
    
}
