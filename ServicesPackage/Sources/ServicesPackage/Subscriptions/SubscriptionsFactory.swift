//
//  File.swift
//  
//
//  Created by Josip Hranić on 28.09.2021..
//

import Foundation

class SubscriptionsFactory {
    
    private let services: Services
    
    init(services: Services) {
        self.services = services
    }
    
    func noSessionSubscriptions() -> [Subscription] {
        []
    }

    func sessionSubscriptions() -> [Subscription] {
        [ReachabilitySubscription(reachabilityService: services.reachabilityService)]
    }
}
