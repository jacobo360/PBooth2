//
//  Downloader.swift
//  PBooth
//
//  Created by Jacobo Koenig on 8/9/16.
//  Copyright © 2016 Jacobo Koenig. All rights reserved.
//

import Cocoa

extension Dictionary {
    mutating func merge<K, V>(dict: [K: V]){
        for (k, v) in dict {
            self.updateValue(v as! Value, forKey: k as! Key)
        }
    }
}

class Downloader: NSViewController, EOSReadDataDelegate {

    var cameras: [EOSCamera] = []
    var progress: Int = 0
    var dict: [String: NSImage] = [:]
    var sorted: [String: NSImage] = [:]
    var defaults = NSUserDefaults.standardUserDefaults()
    var cameraMatch = true
    var images: [NSImage] = []
    
    @IBOutlet weak var progBar: NSProgressIndicator!
    @IBOutlet weak var progLbl: NSTextField!
    @IBOutlet weak var spinner: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if cameras.count == 0 {
            generalAlert("No cameras Detected", text: "There seems to be no cameras connected and turned on, please check the connection and try again")
        }
        
        //Set up Design
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.whiteColor().CGColor
        spinner.startAnimation(self)

        for cam in cameras {
            let serial = cameraFunctionality().getSerial(self, camera: cam)
            let files: [EOSFile] = cameraFunctionality().getToFinalDirectory(cam)
            files.last!.readDataWithDelegate(self, contextInfo: serial)
        }
        
    }
    
    func getLastFile(cam: EOSCamera, serial: String) {
        let files: [EOSFile] = cameraFunctionality().getToFinalDirectory(cam)
        files.last!.readDataWithDelegate(self, contextInfo: serial)
    }
    
    func didReadData(data: NSData!, forFile file: EOSFile!, contextInfo: AnyObject!, error: NSError!) {

        var ocurrence = false
        
        if error != nil && ocurrence == false {
            ocurrence = true
            dict = [:]
            generalAlert("Error", text: "An error ocurred while downloading a photography.")
        }
        
        if ocurrence == false {
            progress += 1
            dict[contextInfo as! String] = NSImage(data: data)!
            if progress < cameras.count {
                progBar.doubleValue = Double(progress)/Double(cameras.count)
                if progress == 1 {progBar.startAnimation(self)}
                progLbl.stringValue = "Downloading Photography: \(String(progress+1))/\(String(cameras.count))"
            } else {
                orderPicturesAndSegue()
            }
        }

    }
    
    func orderPicturesAndSegue() {
        images = []
        
        //Set up order before segueing.
        if let orderArray = defaults.objectForKey("cameraOrder") as? [Int:String] {
            
            //Check all cameras connected are registered
            //Check all serials are contained
            let listCurrent = NSSet(array: Array(dict.keys))
            let listRegistered = NSSet(array: Array(orderArray.values))
            if listCurrent.isSubsetOfSet(listRegistered as Set<NSObject>) {
                for i in orderArray.keys.sort(<) {
                    if dict[orderArray[i]!] != nil {
                        images.append(dict[orderArray[i]!]!)
                    }
                }
            } else {
                sortAlert()
                images = Array(dict.values)
            }
            
        } else { images = Array(dict.values) }
        
        self.performSegueWithIdentifier("toTab", sender: self)
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toTab" {
            let dVC = segue.destinationController as! TabView
            let session = dVC.childViewControllers[0] as! MySession
            let myCams = dVC.childViewControllers[2] as! MyCameras
            session.camMatch = cameraMatch
            session.pictures = dict
            myCams.connectedCameras = cameras
            session.images = images
        }
    }
    
    func getImages() -> [NSImage] {
        images = []
        for i in 0..<17 {
            images.append(NSImage(named: String(i+1))!)
        }
        return images
    }
    
    func generalAlert(question: String, text: String) {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = question
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlertStyle.WarningAlertStyle
        myPopup.addButtonWithTitle("OK")
        let res = myPopup.runModal()
        
        if res == NSAlertFirstButtonReturn {
            let triggerTime = (Int64(NSEC_PER_SEC) * 1)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                self.performSegueWithIdentifier("back", sender: self)
            })
        }
    }
    
    func sortAlert() {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = "Camera Registration"
        myPopup.informativeText = "Not all of the currently connected cameras are registered, images will be sorted randomly"
        myPopup.alertStyle = NSAlertStyle.WarningAlertStyle
        myPopup.addButtonWithTitle("OK")
        let res = myPopup.runModal()
        
        if res == NSAlertFirstButtonReturn {
            
        }
    }
    
}
