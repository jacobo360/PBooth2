//
//  CameraFunctionality.swift
//  PBooth
//
//  Created by Jacobo Koenig on 8/9/16.
//  Copyright © 2016 Jacobo Koenig. All rights reserved.
//

import Cocoa

class cameraFunctionality {
    
    //Get Cameras and Open its Session
    func getCamsWithOpenSession(vc: ViewController) -> [EOSCamera] {
        print("getting cams")
        var cameras: [EOSCamera] = []
        let cameraList = EOSManager.sharedManager().getCameras()
        
        for camera in cameraList {
            
            let cam = camera as! EOSCamera
            
            do {
                //openSession might be instance dependant (cant be called from another class)
                try cam.openSession()
                cameras.append(cam)
                vc.cameraNumLbl.stringValue = "There are \(cameras.count) cameras connected"
            } catch {
                generalAlert("Could not open session on camera \(camera.index)", text: "Please restart the program to load cameras again")
            }
        }
        
        return cameras
    }
    
    
    //Get final Directory with photos
    func getToFinalDirectory(cam: EOSCamera) -> [EOSFile] {
        do {
            let volumeList = cam.volumes()
            let volume = volumeList[0] as! EOSVolume
            for number in volume.files() {
                
                let num = number as! EOSFile
                
                let num2 = num.files() as! [EOSFile]
                try print("num2 " + num2[1].info().name)
//                let num3 = num2[1].files() as! [EOSFile]
//                try print(num3[num3.count - 1].info().name)
//                return num3
            }
        } catch {
            //Handle Error
            return []
        }
        return []
    }
    
    func getLastPictureTaken(file: [EOSFile]) -> EOSFile {
        return file.last!
    }
    
    func getSerials(cameras: [EOSCamera]) -> [String] {
        var cameraSerials: [String] = []
        for camera in cameras {
            do {
                try cameraSerials.append(camera.stringValueForProperty(EOSProperty.SerialNumber))
            } catch {
                print("Error getting serial number")
            }
        }
        return cameraSerials
    }
    
    //Alert
    func generalAlert(question: String, text: String) {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = question
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlertStyle.WarningAlertStyle
        myPopup.addButtonWithTitle("OK")
        let res = myPopup.runModal()
        
        if res == NSAlertFirstButtonReturn {
            //Should Restart Program-Handle Error
        }
    }

}