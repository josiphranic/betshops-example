//
//  File.swift
//  
//
//  Created by Josip Hranić on 23.09.2021..
//

import Foundation

public class Services {
    
    public init() {
        
    }
    
    public var apiClientService: APIClientService { APIClientService.shared }
    public var locationService: LocationService { LocationService.shared }
    public var clusteringService: ClusteringService { ClusteringService.shared }
    public var reachabilityService: ReachabilityService { ReachabilityService.shared }
}
