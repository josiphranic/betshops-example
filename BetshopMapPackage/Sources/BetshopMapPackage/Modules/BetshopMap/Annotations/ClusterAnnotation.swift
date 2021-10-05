//
//  File.swift
//  
//
//  Created by Josip Hranić on 01.10.2021..
//

import Foundation
import MapKit

class ClusterAnnotation: MKPointAnnotation {
    
    let members: [BetshopMapModel]
    var viewFrame: CGRect?
    var previousFrame: CGRect?
    
    init(members: [BetshopMapModel]) {
        self.members = members
        super.init()
        if let coordinate = members.randomElement()?.coordinates {
            self.coordinate = coordinate
        }
     }

    override func isEqual(_ object: Any?) -> Bool {
        guard let annotaion = object as? ClusterAnnotation else {
            return false
        }

        return members == annotaion.members
    }
    
    public static func == (lhs: ClusterAnnotation, rhs: ClusterAnnotation) -> Bool {
        lhs.members == rhs.members
    }

    override var hash: Int {
        members.hashValue
    }
}
