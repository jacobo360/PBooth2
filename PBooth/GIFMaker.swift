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
    
    func createGIF(with images: [NSImage], loopCount: Int = 0, frameDelay: Double) {
        
        let destinationURL = NSURL(fileURLWithPath: "/Users/jacobokoenig/Desktop/")
        let destinationGIF = CGImageDestinationCreateWithURL(destinationURL, kUTTypeGIF, images.count, nil)!
        
        // The final size of your GIF. This is an optional parameter
        //var rect = NSMakeRect(0, 0, 350, 250)
        
        // This dictionary controls the delay between frames
        // If you don't specify this, CGImage will apply a default delay
        let properties = [
            (kCGImagePropertyGIFDictionary as String): [(kCGImagePropertyGIFDelayTime as String): 1.0/16.0]
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
    }
    
}