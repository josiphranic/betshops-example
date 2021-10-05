//
//  File.swift
//  
//
//  Created by Josip Hranić on 24.09.2021..
//

import Foundation
import MapKit

extension MKMapView {
    
    func centerToLocation(location: CLLocationCoordinate2D,
                          regionRadius: CLLocationDistance = 100_000) {
        let coordinateRegion = MKCoordinateRegion(center: location,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
    
    func getTopRightCoordinate() -> CLLocationCoordinate2D {
        let topRightPoint: CGPoint = .init(x: bounds.origin.x + bounds.size.width, y: bounds.origin.y)
        let topRightCoordinate = convert(topRightPoint, toCoordinateFrom: self)
        
        return topRightCoordinate
    }

    func getBottomLeftCoordinate() -> CLLocationCoordinate2D {
        let bottomLeftPoint: CGPoint = .init(x: bounds.origin.x, y: bounds.origin.y + bounds.size.height)
        let bottomLeftCoordinate = convert(bottomLeftPoint, toCoordinateFrom: self)
        
        return bottomLeftCoordinate
    }
}
