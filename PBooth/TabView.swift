//
//  TabView.swift
//  PBooth
//
//  Created by Jacobo Koenig on 8/9/16.
//  Copyright © 2016 Jacobo Koenig. All rights reserved.
//

import Cocoa

class TabView: NSTabViewController {

    var configMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do view setup here.
        self.tabView.tabViewItems[0].image = NSImage(named: "Aperture_Black")!
        self.tabView.tabViewItems[1].image = NSImage(named: "Color_Lens")!
        self.tabView.tabViewItems[2].image = NSImage(named: "Switch_Camera")!
        
        // Disable tab[0] in config mode
        if configMode == true {
            self.removeTabViewItem(self.tabViewItems[0])
        }
        
    }
    
}
