//
//  AppDelegate.swift
//  PBooth
//
//  Created by Jacobo Koenig on 8/5/16.
//  Copyright © 2016 Jacobo Koenig. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {

    let manager: EOSManager = EOSManager.sharedManager()

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        do {
          try manager.load()
        } catch {
            print("could not load")
        }
    
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
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
                
                // create a Save Panel to choose a file path to save to
                let dlg = NSSavePanel()
                // use the name fields value to suggest a name for the file
                dlg.nameFieldStringValue = ""
                // run the Save Panel and handle an OK selection
                if (dlg.runModal() == NSFileHandlingPanelOKButton) {
                    // get the URL of the selected file path
                    let saveUrl = dlg.URL
                    
                    // archive the dictionary and save to the file path
                    viewController.expGIF((saveUrl?.URLByAppendingPathExtension(dlg.nameFieldStringValue))!)
                }
                
//                let msg = NSAlert()
//                msg.addButtonWithTitle("OK")      // 1st button
//                msg.addButtonWithTitle("Cancel")  // 2nd button
//                msg.messageText = "Choose a File Name"
//                
//                let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
//                
//                msg.accessoryView = txt
//                let response: NSModalResponse = msg.runModal()
//                
//                if (response == NSAlertFirstButtonReturn) {
//                    viewController.expGIF(txt.stringValue)
//                } else {
//                
//                }
                
                //viewController.expGIF()
                
            }
        }
    }
    
    @IBAction func restart(sender: AnyObject) {
        if let current = NSApplication.sharedApplication().mainWindow {
            let win = NSWindow(contentRect: current.frame,
                           styleMask: NSResizableWindowMask,
                           backing: NSBackingStoreType.Buffered, defer: true)
        
            win.contentViewController = ViewController()
            win.makeKeyAndOrderFront(win)
        } else {
            let win = NSWindow(contentRect: NSMakeRect(100, 100, 600, 200),
                               styleMask: NSResizableWindowMask,
                               backing: NSBackingStoreType.Buffered, defer: true)
            
            win.contentViewController = ViewController()
            win.makeKeyAndOrderFront(win)
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
    
}

