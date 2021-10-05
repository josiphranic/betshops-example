//
//  File.swift
//  
//
//  Created by Josip Hranić on 25.09.2021..
//

import UIKit

public extension UIImage {
    
    func resize(to newSize: CGSize) -> UIImage? {
        guard size != newSize else {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
