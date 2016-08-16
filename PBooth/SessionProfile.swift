//
//  Profile.swift
//  PBooth
//
//  Created by Jacobo Koenig on 8/15/16.
//  Copyright © 2016 Jacobo Koenig. All rights reserved.
//

import Cocoa

class SessionProfile: NSObject, NSCoding {
    
    var name: String = ""
    var cameraCount: Int = 0
    var cameraOrder: [Int] = []
    
    init(name: String, cameraCount: Int, cameraOrder: [Int]) {
        self.name = name
        self.cameraCount = cameraCount
        self.cameraOrder = cameraOrder
    }
    
    // MARK: NSCoding
    
    required convenience init?(coder decoder: NSCoder) {
        guard let name = decoder.decodeObjectForKey("name") as? String,
            let cameraCount = decoder.decodeIntegerForKey("cameraCount") as? Int,
            let cameraOrder = decoder.decodeObjectForKey("cameraOrder") as? [Int]
            else { return nil }
        
        self.init(
            name: name,
            cameraCount: decoder.decodeIntegerForKey("cameraCount"),
            cameraOrder: cameraOrder
        )
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.name, forKey: "name")
        coder.encodeInt(Int32(self.cameraCount), forKey: "cameraCount")
        coder.encodeObject(self.cameraOrder, forKey: "cameraOrder")
    }
}
