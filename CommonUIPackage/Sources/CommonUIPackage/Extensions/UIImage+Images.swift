//
//  File.swift
//  
//
//  Created by Josip Hranić on 22.09.2021..
//

import UIKit

public extension UIImage {
    
    class var blueCloverPin: UIImage? { imageNamed("BlueCloverPin") }
    class var greenCloverPin: UIImage? { imageNamed("GreenCloverPin") }
    class var greenPin: UIImage? { imageNamed("GreenPin") }
    class var closeIcon: UIImage? { imageNamed("CloseIcon") }
    class var phoneHandset: UIImage? { imageNamed("PhoneHandset") }
    class var warning: UIImage? { imageNamed("Warning") }
    class var info: UIImage? { imageNamed("Info") }
    
    private class func imageNamed(_ named: String) -> UIImage? {
        UIImage(named: named, in: Bundle.module, compatibleWith: nil)
    }
}
