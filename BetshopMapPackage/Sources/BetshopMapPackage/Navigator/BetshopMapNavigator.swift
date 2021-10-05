//
//  File.swift
//  
//
//  Created by Josip Hranić on 22.09.2021..
//

import UIKit
import BasePackage
import ServicesPackage

public func makeBetshopMapNavigator() -> BetshopMapNavigator {

    let viewModelFactory = BetshopMapViewModelFactory(services: Services())
    let viewControllerFactory = BetshopMapViewControllerFactory(viewModelFactory: viewModelFactory)

    return BetshopMapNavigator(viewControllerFactory: viewControllerFactory)
}

public enum BetshopMapScreen {
    case betshopsMap
}

public class BetshopMapNavigator: BaseNavigator {

    private let viewControllerFactory: BetshopMapViewControllerFactory
    private let rootNavigationController = UINavigationController()
    
    init(viewControllerFactory: BetshopMapViewControllerFactory) {
        self.viewControllerFactory = viewControllerFactory
    }
    
    public func getRootNavigationController() -> UINavigationController {
        rootNavigationController
    }
    
    public func navigate(to screen: BetshopMapScreen, animated: Bool) {
        switch screen {
        case .betshopsMap:
            // TODO check memory leak because navigator is sending self
            let viewController = viewControllerFactory.getViewController(screen: screen, navigator: self)
            navigateOnCurrentNavigationStack(viewController: viewController, animated: true)
        }
    }
}
