//
//  AppDelegate.swift
//  PBooth
//
//  Created by Jacobo Koenig on 8/5/16.
//  Copyright © 2016 Jacobo Koenig. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate, EOSCameraDelegate {

    let manager: EOSManager = EOSManager.sharedManager()
    var showingAlert: Bool = false
    var cameraList: [EOSCamera]?
    var timer = NSTimer()
    let defaults = NSUserDefaults.standardUserDefaults()
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        do {
            try manager.load()
        } catch {
            print("could not load")
        }
        
        
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        if manager.isLoaded {
            
            do {
                try manager.terminate()
            } catch {
                print("could not terminate")
            }
            
        }
    }
    
    @IBAction func expGIF(sender: AnyObject) {
        if let window = NSApplication.sharedApplication().mainWindow {
            if let viewController = window.contentViewController?.childViewControllers[0] as? MySession {
            
                if let url = defaults.objectForKey("save_url") {
                    
                    let int = defaults.integerForKey("sequence")
                    defaults.setInteger(int + 1, forKey: "sequence")
                    
                    let length = String(int).characters.count
                    var name = ""
                    
                    for _ in 0..<(4 - length) {
                        name = "0" + name
                    }
                    
                    name = "PBOOTH_" + name + String(int)
                    
                    let urlWithName = (url as! String) + name
                
                    let loc = NSURL(string: urlWithName )
                    
                    viewController.expGIF((loc!.URLByAppendingPathExtension("gif"))!)
                    
                } else {
                    //Alert No Location Defined
                    generalAlert("No Save Location Defined", text: "Please open a New Session and define your preferred save location with button on the top right of the window")
                }
                
            }
        }
    }

    @IBAction func newSession(sender: AnyObject) {

        if let current = NSApplication.sharedApplication().mainWindow {
            let win = NSWindow(contentRect: current.frame,
                               styleMask: NSResizableWindowMask,
                               backing: NSBackingStoreType.Buffered, defer: true)
            
            win.contentViewController = Downloader()
            win.makeKeyAndOrderFront(win)
        } else {
            let win = NSWindow(contentRect: NSMakeRect(100, 100, 600, 200),
                               styleMask: NSResizableWindowMask,
                               backing: NSBackingStoreType.Buffered, defer: true)
            
            win.contentViewController = Downloader()
            win.makeKeyAndOrderFront(win)
        }
    }
    
    func camera(camera: EOSCamera!, didCreateFile file: EOSFile!) {
        
        newPicsAlert()
        
        do {
            try print(file.info().name)
        } catch {
            print("ERROR PRINTING NAME")
        }
    
    }
    
    func newPicsAlert() {
        
        timer.invalidate()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(self.openWin), userInfo: nil, repeats: false)
                
    }

    func openWin() {
        
        if let current = NSApplication.sharedApplication().mainWindow {
            
            let storyboard = NSStoryboard.init(name: "Main", bundle: nil)
            let vc = storyboard.instantiateControllerWithIdentifier("downloaderID") as! Downloader
            vc.cameras = cameraList!
            current.contentViewController = vc
        }
    }
    
    func generalAlert(question: String, text: String) {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = question
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlertStyle.Warning
        myPopup.addButtonWithTitle("OK")
        let res = myPopup.runModal()
        
        if res == NSAlertFirstButtonReturn {
            //Should Restart Program-Handle Error
        }
    }
    
}

