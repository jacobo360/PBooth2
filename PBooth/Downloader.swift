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
    
    @IBOutlet weak var progBar: NSProgressIndicator!
    @IBOutlet weak var progLbl: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up Design
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.whiteColor().CGColor
        
        for cam in cameras {
            let files: [EOSFile] = cameraFunctionality().getToFinalDirectory(cam)
            downloadLastFile(cam, file: files[files.count-1])
        }
    }
    
    func downloadLastFile(cam: EOSCamera, file: EOSFile) {
        do {
            let directory = NSURL(fileURLWithPath: "/Users/jacobokoenig/Desktop/PBoothPictures/")
            let options = try [EOSDownloadDirectoryURLKey : directory, EOSSaveAsFilenameKey : cam.stringValueForProperty(EOSProperty.SerialNumber), EOSOverwriteKey : false]
            file.downloadWithOptions(options, delegate: self, contextInfo: nil)
        } catch {
            //Handle Error
        }
    }
    
    override func viewWillAppear() {
        if cameras.count == 0 {
            generalAlert("No cameras Detected", text: "There seems to be no cameras connected and turned on, please check the connection and try again")
        }
    }
    
    func didDownloadFile(file: EOSFile!, withOptions options: [NSObject : AnyObject]!, contextInfo: AnyObject!, error: NSError!) {
        
        file.readDataWithDelegate(self, contextInfo: nil)
        
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
        //Check if this method gets file is NSData
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toTab" {
            let dVC = segue.destinationController as! TabView
            let session = dVC.childViewControllers[0] as! MySession
            //session.images = images
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
            self.dismissViewController(self)
        }
    }
    
}
