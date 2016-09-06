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
    
    var cameraOrder: [Int:String] = [:]
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
        if let orderArray = defaults.objectForKey("cameraOrder") as? [Int:String] {
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
        
        if let orderArray = defaults.objectForKey("cameraOrder") as? [Int:String] {
            cameraOrder = orderArray
            if cameraOrder.keys.contains(Int(tField.stringValue)!) {
                tField.stringValue = ""
                textFieldAlert("Error", mess: "The position is already taken")
            } else {
                cameraOrder[Int(tField.stringValue)!] = serial
                defaults.setObject(cameraOrder, forKey: "cameraOrder")
                reconnect()
            }
        
        } else {
            let dict = [Int(tField.stringValue)!:serial]
            print(dict)
            defaults.setObject(dict, forKey: "cameraOrder")
            reconnect()
        }
        
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
