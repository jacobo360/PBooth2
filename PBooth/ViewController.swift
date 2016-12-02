//
//  ViewController.swift
//  PBooth
//
//  Created by Jacobo Koenig on 8/5/16.
//  Copyright © 2016 Jacobo Koenig. All rights reserved.
//

import Cocoa

let TEAL = NSColor(SRGBRed: 1.00, green:0.94, blue:0.00, alpha:1.0)
let PINK = NSColor(SRGBRed: 1.00, green:0.25, blue:0.51, alpha:1.0)

class ViewController: NSViewController {
    
    var camArray: [EOSCamera] = []
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var navView: NSView!
    @IBOutlet weak var cameraNumLbl: NSTextField!
    @IBOutlet weak var shutterBtn: NSButton!
    @IBOutlet weak var startBtn: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up design
        navView.wantsLayer = true
        navView.layer?.backgroundColor = TEAL.CGColor
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.whiteColor().CGColor
        startBtn.hidden = true
        
        //Get Cameras
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(1), target: self, selector: #selector(ViewController.go), userInfo: nil, repeats: false)
    }
    
    func go() {
        
        //Get Cameras
        camArray = cameraFunctionality().getCamsWithOpenSession(self)
        startBtn.hidden = false
    }
    
    @IBAction func startBtn(sender: AnyObject) {
        self.performSegueWithIdentifier("downloader", sender: self)
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func resetLocation(sender: AnyObject) {
        
        // create a Save Panel to choose a file path to save to
        let dlg = NSOpenPanel()
        dlg.canChooseFiles = false
        dlg.canChooseDirectories = true
        
        // run the Save Panel and handle an OK selection
        if (dlg.runModal() == NSFileHandlingPanelOKButton) {
            // get the URL of the selected file path
            print(dlg.URL)
            
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
            let myCams = configVC.childViewControllers[2] as! MyCameras
            myCams.connectedCameras = camArray
        }
        
    }
    
}

