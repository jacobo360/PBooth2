//
//  MySession.swift
//  PBooth
//
//  Created by Jacobo Koenig on 8/7/16.
//  Copyright © 2016 Jacobo Koenig. All rights reserved.
//

import Cocoa

class MySession: NSViewController, NSTableViewDelegate, NSTableViewDataSource, DBRestClientDelegate {

    let defaults = NSUserDefaults.standardUserDefaults()
    var restClient = DBRestClient()
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var imgView: NSImageView!
    @IBOutlet weak var selectedProfile: NSTextField!
    
    var images:[NSImage] = []
    var cameraOrder: [Int] = []
    var cameraCount: Int = 0
    var camMatch = false
    var pictures: [String: NSImage] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set Up and Design
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.whiteColor().CGColor
        tableView.registerForDraggedTypes([NSGeneralPboard])
        tableView.allowsColumnSelection = false
        
        //Set Up Selected Profile
        restartProfile()
        
        //DB
        restClient = DBRestClient(session: DBSession.sharedSession())
        print(restClient)
        self.restClient.delegate = self
    }
    
    override func viewDidAppear() {
        let win = self.view.window
        win!.setFrame(NSMakeRect(win!.frame.minX, win!.frame.minY, win!.frame.width, win!.frame.height+1), display: true)
        
        //Close sessions if open
        //cameraFunctionality().closeS()
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        let table = notification.object as! NSTableView
        
        //check to see if we have custom profile to use camera order for image in position
        var selection: Int = 0
        
        //CHANGED AFTER COMPLETION, TRIED WITH SAMPLE IMAGES- BE CAREFUL TO UNCOMMENT IF THERE ARE ISSUES
//        if let data = defaults.objectForKey("selectedProfile") as? NSData {
//            let profile = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! SessionProfile
//            self.selectedProfile.stringValue = profile.name
//            cameraOrder = profile.cameraOrder
            selection = cameraOrder[table.selectedRow]
//        } else {
//            selection = table.selectedRow + 1
//        }
        imgView.image = images[selection - 1]
    }
    
    func tableView(tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return cameraOrder.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        tableView.cell?.title = String(cameraOrder[row])
        return cameraOrder[row]
        
    }
    
    func tableView(tableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
        
        let data:NSData = NSKeyedArchiver.archivedDataWithRootObject(rowIndexes)
        let registeredTypes:[String] = [NSGeneralPboard]
        pboard.declareTypes(registeredTypes, owner: self)
        pboard.setData(data, forType: NSGeneralPboard)
        
        return true
    }
    
    func tableView(tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        
        if dropOperation == .Above {
            return .Move
        }
        return .None
    }
    
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        
        let data: NSData = info.draggingPasteboard().dataForType(NSGeneralPboard)!
        let rowIndexes: NSIndexSet = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSIndexSet
        let value: Int = cameraOrder[rowIndexes.firstIndex]
        
        if rowIndexes.firstIndex < row {
            cameraOrder.insert(value, atIndex: row)
            cameraOrder.removeAtIndex(rowIndexes.firstIndex)
            images.insert(images[rowIndexes.firstIndex], atIndex: row)
            images.removeAtIndex(rowIndexes.firstIndex)
        } else if rowIndexes.firstIndex > row {
            cameraOrder.removeAtIndex(rowIndexes.firstIndex)
            cameraOrder.insert(value, atIndex: row)
            images.insert(images[rowIndexes.firstIndex], atIndex: row)
            images.removeAtIndex(rowIndexes.firstIndex + 1)
        }
        
        tableView.reloadData()
        return true
    }

    @IBAction func duplicateBtn(sender: AnyObject) {
        if tableView.selectedRow != -1 {
            let row = tableView.selectedRow
            let value: Int = cameraOrder[row]
            cameraOrder.insert(value, atIndex: row)
            images.insert(images[row], atIndex: row)
            tableView.reloadData()
        } else {
            selectionAlert("Duplicate")
        }
    }
    
    @IBAction func deleteBtn(sender: AnyObject) {
        //NOTE: Select previous row after duplication
        if tableView.selectedRow != -1 {
            let row = tableView.selectedRow
            cameraOrder.removeAtIndex(row)
            images.removeAtIndex(row)
            tableView.reloadData()
        } else {
            selectionAlert("Delete")
        }
    }
    
    @IBAction func changeProfile(sender: AnyObject) {
        let a = NSAlert()
        a.messageText = "Change Default Profile"
        a.addButtonWithTitle("Done")
        a.addButtonWithTitle("Cancel")
        a.alertStyle = NSAlertStyle.Warning
        
        let dDown = NSPopUpButton(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        
        var profileList: [SessionProfile] = []
        
        if let data = defaults.objectForKey("profiles") as? NSData {
            profileList = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [SessionProfile]
            var nameList: [String] = []
            for prof in profileList {
                nameList.append(prof.name)
            }
            dDown.removeAllItems()
            dDown.addItemsWithTitles(nameList)
        } else {
            defaultAlert("Setting Default Profile")
        }
        
        a.accessoryView = dDown
        
        a.beginSheetModalForWindow(self.view.window!, completionHandler: { (modalResponse) -> Void in
            if modalResponse == NSAlertFirstButtonReturn {
//                print(dDown.selectedItem)
//                print(dDown.indexOfSelectedItem)
                if dDown.selectedItem != nil && dDown.indexOfSelectedItem != -1 {
                    let selection = profileList[dDown.indexOfSelectedItem]
                    let data = NSKeyedArchiver.archivedDataWithRootObject(selection)
                    self.defaults.setObject(data, forKey: "selectedProfile")
                    self.selectedProfile.stringValue = selection.name
                    self.restartProfile()
                } else {
                    self.defaults.removeObjectForKey("selectedProfile")
                    self.restartProfile()
                }
            }
        })
    }
    
    
    
    func selectionAlert(activity: String) {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = "Can't \(activity)"
        myPopup.informativeText = "Please select a row on the table to \(activity.lowercaseString) it"
        myPopup.alertStyle = NSAlertStyle.Warning
        myPopup.addButtonWithTitle("OK")
        let res = myPopup.runModal()
        
        if res == NSAlertFirstButtonReturn {
            //Should Restart Program-Handle Error
        }
    }
    
    func restartProfile() {
        if let data = defaults.objectForKey("selectedProfile") as? NSData {
            let profile = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! SessionProfile
            self.selectedProfile.stringValue = profile.name
            cameraOrder = profile.cameraOrder
            cameraCount = profile.cameraCount
            checkImagesAgainstProfile(profile)
        } else {
            //GO DEFAULT
            defaultProfile()
        }
    }
    
    func defaultProfile() {
        selectedProfile.stringValue = "Default"
        cameraOrder = []
        for i in 0..<images.count {
            cameraOrder.append(i+1)
        }
        cameraCount = cameraOrder.count
        tableView.reloadData()
    }
    
    func checkImagesAgainstProfile(profile: SessionProfile) {
        if images.count != profile.cameraCount {
            defaultAlert("Image Count do not match the profile's Camera Count")
        }
    }
    
    func defaultAlert(text: String) {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = "Setting the Default Profile"
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlertStyle.Warning
        myPopup.addButtonWithTitle("OK")
        let res = myPopup.runModal()
        
        if res == NSAlertFirstButtonReturn {
            defaultProfile()
        }
    }

    func expGIF(name: NSURL) {
        
        var finalImages: [NSImage] = []
        print(cameraOrder)
        for i in cameraOrder {
            finalImages.append(images[i-1])
        }
        
        GIFMaker().createGIF(with: finalImages, name: name, frameDelay: 0.1)
        uploadGIF(name)
    }
    
//    @IBAction func exportGIF(sender: NSButton) {
//        //expGIF()
//    }
    
    func uploadGIF(destinationURL: NSURL) {
        let name = destinationURL.lastPathComponent
        self.restClient.uploadFile(name, toPath: "/", withParentRev: nil, fromPath: destinationURL.path)
    }
    
    func restClient(client: DBRestClient!, uploadedFile destPath: String!, fromUploadId uploadId: String!, metadata: DBMetadata!) {
        print(metadata.path)
    }
    
    func restClient(client: DBRestClient!, uploadFileFailedWithError error: NSError!) {
        print(error)
    }
    
    func restClient(client: DBRestClient!, uploadProgress progress: CGFloat, forFile destPath: String!, from srcPath: String!) {
        if progress == 1.0 {
            generalAlert("GIF Uploaded", text: "Your GIF has been saved to your computer and uploaded to Dropbox under: \(destPath)")
        } else {
            print(progress)
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
