//
//  File.swift
//  
//
//  Created by Josip Hranić on 21.09.2021..
//

import Foundation
import ServicesPackage
import BasePackage

struct RootViewModelFactory {
    
    private let services = Services()

    func getRootViewModel(navigator: RootNavigator) -> RootViewModel {
        RootViewModel(rootNavigator: navigator, reachabilityService: services.reachabilityService)
    }
}
