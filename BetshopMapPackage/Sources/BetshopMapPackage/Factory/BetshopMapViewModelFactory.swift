//
//  File.swift
//  
//
//  Created by Josip Hranić on 22.09.2021..
//

import Foundation
import BasePackage
import ServicesPackage

struct BetshopMapViewModelFactory {
    
    private let services: Services
    
    init(services: Services) {
        self.services = services
    }

    func getBetshopMapViewModel (navigator: BetshopMapNavigator) -> BetshopMapViewModel {
        BetshopMapViewModel(navigator: navigator,
                            apiClientService: services.apiClientService,
                            locationService: services.locationService,
                            clusteringService: services.clusteringService)
    }
}
