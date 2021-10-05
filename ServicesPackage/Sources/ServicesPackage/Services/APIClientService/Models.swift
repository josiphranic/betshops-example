//
//  File.swift
//  
//
//  Created by Josip Hranić on 24.09.2021..
//

import Foundation
import CoreLocation

public struct BetshopsBoundingBox {

    let topRightLatitude: Double
    let topRightLongitude: Double
    let bottomLeftLatitude: Double
    let bottomLeftLongitude: Double
    
    public init(topRightCoordinate: CLLocationCoordinate2D,
                bottomLeftCoordinate: CLLocationCoordinate2D) {
        self.topRightLatitude = topRightCoordinate.latitude
        self.topRightLongitude = topRightCoordinate.longitude
        self.bottomLeftLatitude = bottomLeftCoordinate.latitude
        self.bottomLeftLongitude = bottomLeftCoordinate.longitude
    }
    
    public init(topRightLatitude: Double,
                topRightLongitude: Double,
                bottomLeftLatitude: Double,
                bottomLeftLongitude: Double) {
        self.topRightLatitude = topRightLatitude
        self.topRightLongitude = topRightLongitude
        self.bottomLeftLatitude = bottomLeftLatitude
        self.bottomLeftLongitude = bottomLeftLongitude
    }
    
    var asUrlParameterValue: String {
        "\(topRightLatitude),\(topRightLongitude),\(bottomLeftLatitude),\(bottomLeftLongitude)"
    }
}

public struct Betshops: Decodable {
    
    public let count: Int
    public let betshops: [Betshop]
}

public struct Betshop: Decodable {
    
    public let id: Int
    public let name: String
    public let location: BetshopLocation
    public let county: String
    public let cityId: Int
    public let city: String
    public let address: String
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case location
        case county
        case cityId = "city_id"
        case city
        case address
    }
}

public struct BetshopLocation: Decodable {
    
    public let latitude: Double
    public let longitude: Double
    
    private enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
    }
}
