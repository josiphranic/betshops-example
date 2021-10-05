//
//  File.swift
//  
//
//  Created by Josip Hranić on 22.09.2021..
//

import UIKit

public extension UIColor {

    class var appGreen: UIColor { colorFrom(red: 140, green: 187, blue: 21) }
    class var clusterBlue: UIColor { colorFrom(red: 69, green: 97, blue: 162) }
    class var darkYellow: UIColor { colorFrom(red: 139, green: 128, blue: 0) }
    class var darkBlue: UIColor { colorFrom(red: 48, green: 77, blue: 195) }
    
    class func colorFrom(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        UIColor(red: red / 255,
                green: green / 255,
                blue: blue / 255,
                alpha: 1)
    }
}
