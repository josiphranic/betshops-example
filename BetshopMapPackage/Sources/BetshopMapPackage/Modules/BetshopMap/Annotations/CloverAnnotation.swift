//
//  File.swift
//  
//
//  Created by Josip Hranić on 25.09.2021..
//

import Foundation
import MapKit

class CloverAnnotation: MKPointAnnotation {
    
    let mapModel: BetshopMapModel
    var previousClusterFrame: CGRect?
    
    init(coordinate: CLLocationCoordinate2D,
         mapModel: BetshopMapModel) {
        self.mapModel = mapModel
        super.init()
        self.coordinate = coordinate
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let annotaion = object as? CloverAnnotation else {
            return false
        }

        return mapModel.id == annotaion.mapModel.id
    }
    
    public static func == (lhs: CloverAnnotation, rhs: CloverAnnotation) -> Bool {
        lhs.mapModel.id == rhs.mapModel.id
    }

    override var hash: Int {
        mapModel.id.hashValue
    }
}
