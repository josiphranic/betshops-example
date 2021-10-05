//
//  File.swift
//  
//
//  Created by Josip Hranić on 27.09.2021..
//

import Foundation
import CoreLocation
import RxCoreLocation
import RxSwift

public class LocationService {
    
    private let locationManager = CLLocationManager()
    static let shared = LocationService()
    
    private init() {
        setup()
    }
}

// MARK: Public properties
public extension LocationService {

    var location: Observable<CLLocation> {
        locationManager
            .rx
            .location
            .compactMap { $0 }
    }
}

// MARK: Private methods
private extension LocationService {
    
    func setup() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
}
