//
//  File.swift
//  
//
//  Created by Josip Hranić on 22.09.2021..
//

import UIKit
import BasePackage

class BetshopMapViewControllerFactory: BaseViewControllerFactory {

    private let viewModelFactory: BetshopMapViewModelFactory
    
    required init(viewModelFactory: BetshopMapViewModelFactory) {
        self.viewModelFactory = viewModelFactory
    }
    
    func getViewController(screen: BetshopMapScreen, navigator: BetshopMapNavigator) -> UIViewController {
        switch screen {
        case .betshopsMap:
            let viewModel = viewModelFactory.getBetshopMapViewModel(navigator: navigator)
            return BetshopMapViewController(viewModel: viewModel)
        }
    }
}
