//
//  ViewController.swift
//  PBooth
//
//  Created by Jacobo Koenig on 8/5/16.
//  Copyright © 2016 Jacobo Koenig. All rights reserved.
//

import Cocoa

let TEAL = NSColor(SRGBRed: 0.00, green:0.59, blue:0.53, alpha:1.0)
let PINK = NSColor(SRGBRed: 1.00, green:0.25, blue:0.51, alpha:1.0)

class ViewController: NSViewController, EOSReadDataDelegate {
    
    var camArray: [EOSCamera] = []
    
    @IBOutlet weak var navView: NSView!
    @IBOutlet weak var cameraNumLbl: NSTextField!
    @IBOutlet weak var shutterBtn: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up design
        navView.wantsLayer = true
        navView.layer?.backgroundColor = TEAL.CGColor
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.whiteColor().CGColor
        
        //Get Cameras
        _ = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(1), target: self, selector: #selector(ViewController.go), userInfo: nil, repeats: false)
    }
    
    func go() {
        //Get Cameras
        camArray = cameraFunctionality().getCamsWithOpenSession(self)
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "downloader" {
            let downloaderVC = segue.destinationController as! Downloader
            downloaderVC.cameras = camArray
        } else if segue.identifier == "toTab" {
            let configVC = segue.destinationController as! TabView
            //configVC.removeTabViewItem(configVC.tabViewItems[0])
            configVC.configMode = true
            configVC.selectedTabViewItemIndex = 2
        }
        
    }
    
    func checkCam() {
        print("checking cam")
        let cameraList = EOSManager.sharedManager().getCameras()
        
        for camera in cameraList {
            
            let cam = camera as! EOSCamera
            
            do {
                try cam.openSession()
                let serialNumber = try cam.stringValueForProperty(EOSProperty.SerialNumber)
                print(serialNumber)
                
                
                let volumeList = cam.volumes()
                let volume = volumeList[0] as! EOSVolume
                for number in volume.files() {
                    
                    let num = number as! EOSFile
                    
                        let num2 = num.files() as! [EOSFile]
                        for n in num2 {
                            try print(n.info().name)
                            let num3 = n.files() as! [EOSFile]
                            //let directory = NSURL(fileURLWithPath: "/Users/jacobokoenig/Desktop/ThePicture/")
                            //let options = try [EOSDownloadDirectoryURLKey : directory, EOSSaveAsFilenameKey : num3[num3.count - 19].info().name, EOSOverwriteKey : false]
                            num3[num3.count - 4].readDataWithDelegate(self, contextInfo: nil)
                    }
                }
                
            } catch {
                
            }
        }
    }
    
    func didReadData(data: NSData!, forFile file: EOSFile!, contextInfo: AnyObject!, error: NSError!) {
        //Check if data is an NSImage
        print("didReadData")
        shutterBtn.image = NSImage(data: data)
    }
    
}

