//
//  Downloader.swift
//  PBooth
//
//  Created by Jacobo Koenig on 8/9/16.
//  Copyright © 2016 Jacobo Koenig. All rights reserved.
//

import Cocoa

class Downloader: NSViewController, EOSDownloadDelegate, EOSReadDataDelegate {

    var cameras: [EOSCamera] = []
    var progress: Int = 0
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
            let files: [EOSFile] = cameraFunctionality().getToFinalDirectory(cam)
            files.last!.readDataWithDelegate(self, contextInfo: nil)
        }
    }
    
    override func viewDidAppear() {
    }
    
    func didDownloadFile(file: EOSFile!, withOptions options: [NSObject : AnyObject]!, contextInfo: AnyObject!, error: NSError!) {
        
        var ocurrence = false
        
        //Need To Handle Error
        if error != nil && ocurrence == false {
            ocurrence = true
            generalAlert("Error", text: "An error ocurred while downloading a photography.")
        }
        
        if ocurrence == false {
            progress += 1
            if progress < cameras.count {
                progBar.doubleValue = Double(progress)/Double(cameras.count)
                if progress == 1 {progBar.startAnimation(self)}
                progLbl.stringValue = "Downloading Photography: \(String(progress+1))/\(String(cameras.count))"
            } else {
                //Set up order and profile before segue
                self.performSegueWithIdentifier("toTab", sender: self)
            }
        }
        
    }
    
    func didReadData(data: NSData!, forFile file: EOSFile!, contextInfo: AnyObject!, error: NSError!) {

        var ocurrence = false
        
        //Need To Handle Error
        if error != nil && ocurrence == false {
            ocurrence = true
            images = []
            generalAlert("Error", text: "An error ocurred while downloading a photography.")
        }
        
        if ocurrence == false {
            progress += 1
            images.append(NSImage(data: data)!)
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
        //Set up order before segueing.
        self.performSegueWithIdentifier("toTab", sender: self)
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toTab" {
            let dVC = segue.destinationController as! TabView
            let session = dVC.childViewControllers[0] as! MySession
            let myCams = dVC.childViewControllers[2] as! MyCameras
            myCams.connectedCameras = cameras
            session.images = images
        }
        
    }
    
    func generalAlert(question: String, text: String) {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = question
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlertStyle.WarningAlertStyle
        myPopup.addButtonWithTitle("OK")
        let res = myPopup.runModal()
        
        if res == NSAlertFirstButtonReturn {
            performSegueWithIdentifier("back", sender: self)
        }
    }
    
}
