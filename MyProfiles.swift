//
//  MyProfiles.swift
//  PBooth
//
//  Created by Jacobo Koenig on 8/15/16.
//  Copyright © 2016 Jacobo Koenig. All rights reserved.
//

import Cocoa

class MyProfiles: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet weak var myProfilesTbl: NSTableView!
    @IBOutlet weak var profileTbl: NSTableView!
    @IBOutlet weak var profTblView: NSScrollView!
    @IBOutlet weak var duplicateBtn: NSButton!
    @IBOutlet weak var deleteBtn: NSButton!
    @IBOutlet weak var numLbl: NSTextField!
    @IBOutlet weak var numTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear() {
        setUpProfileMaker()
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        setUpProfileMaker()
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return 1
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        tableView.cell?.title = "1"
        return "1"
    }
    
    func setUpProfileMaker() {
        let pMakeArray: [NSView] = [profTblView, duplicateBtn, deleteBtn, numLbl, numTextField]
        if myProfilesTbl.selectedRow == -1 {
            for pMake in pMakeArray {
                pMake.hidden = true
            }
        } else {
            for pMake in pMakeArray {
                pMake.hidden = false
            }
        }
    }
    
}
