//
//  AppDelegate.swift
//  PBooth
//
//  Created by Jacobo Koenig on 8/5/16.
//  Copyright © 2016 Jacobo Koenig. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

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


}

