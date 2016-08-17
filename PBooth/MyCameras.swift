//
//  MyCameras.swift
//  PBooth
//
//  Created by Jacobo Koenig on 8/16/16.
//  Copyright © 2016 Jacobo Koenig. All rights reserved.
//

import Cocoa

class MyCameras: NSViewController {

    @IBOutlet weak var positionTextField: NSTextField!
    @IBOutlet weak var positionStack: NSStackView!
    @IBOutlet weak var connectionLbl: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set Up Design
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.whiteColor().CGColor
        
        //Set Up Connection
    }
    
}
