//
//  ViewController.swift
//  PBooth
//
//  Created by Jacobo Koenig on 8/5/16.
//  Copyright © 2016 Jacobo Koenig. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, EOSDownloadDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(1), target: self, selector: #selector(ViewController.checkCam), userInfo: nil, repeats: false)
        
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
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
                            let directory = NSURL(fileURLWithPath: "/Users/jacobokoenig/Desktop/ThePicture/")
                            let options = try [EOSDownloadDirectoryURLKey : directory, EOSSaveAsFilenameKey : num3[num3.count - 19].info().name, EOSOverwriteKey : false]
                            num3[num3.count - 19].downloadWithOptions(options, delegate: self, contextInfo: nil)
                    }
                }
                
            } catch {
                
            }
        }
    }
    
    func didDownloadFile(file: EOSFile!, withOptions options: [NSObject : AnyObject]!, contextInfo: AnyObject!, error: NSError!) {
        do {
            try print("printed")
        } catch {
            
        }
    }
}

