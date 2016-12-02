//
//  GIFMaker.swift
//  PBooth
//
//  Created by Jacobo Koenig on 8/12/16.
//  Copyright © 2016 Jacobo Koenig. All rights reserved.
//

import Cocoa
import ImageIO

class GIFMaker {
    
    func createGIF(with images: [NSImage], name: NSURL, loopCount: Int = 0, frameDelay: Double) {
        
        let destinationURL = name
        let destinationGIF = CGImageDestinationCreateWithURL(destinationURL, kUTTypeGIF, images.count, nil)!
        
        // This dictionary controls the delay between frames
        // If you don't specify this, CGImage will apply a default delay
        let properties = [
            (kCGImagePropertyGIFDictionary as String): [(kCGImagePropertyGIFDelayTime as String): frameDelay]
        ]
        
        
        for img in images {
            // Convert an NSImage to CGImage, fitting within the specified rect
            // You can replace `&rect` with nil
            let cgImage = img.CGImageForProposedRect(nil, context: nil, hints: nil)!
            
            // Add the frame to the GIF image
            // You can replace `properties` with nil
            CGImageDestinationAddImage(destinationGIF, cgImage, properties)
        }
        
        // Write the GIF file to disk
        CGImageDestinationFinalize(destinationGIF)
        
        print("GIF DATA: \(NSData(contentsOfURL: destinationURL))")
        let dataedGif = NSData(contentsOfURL: destinationURL)
        
        
    }
    
}
