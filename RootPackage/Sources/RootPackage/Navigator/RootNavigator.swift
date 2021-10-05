//
//  File.swift
//  
//
//  Created by Josip Hranić on 21.09.2021..
//

import UIKit
import BasePackage
import BetshopMapPackage

public func makeRootNavigator() -> RootNavigator {

    let rootViewModelFactory = RootViewModelFactory()
    let rootViewControllerFactory = RootViewControllerFactory(viewModelFactory: rootViewModelFactory)

    return RootNavigator(viewControllerFactory: rootViewControllerFactory)
}

public enum RootScreen {
    case root
}

public class RootNavigator: BaseNavigator {

    private let viewControllerFactory: RootViewControllerFactory
    private let rootNavigationController = UINavigationController()

    init(viewControllerFactory: RootViewControllerFactory) {
        self.viewControllerFactory = viewControllerFactory
    }

    public func getRootNavigationController() -> UINavigationController {
        rootNavigationController
    }

    public func navigate(to screen: RootScreen, animated: Bool) {
        switch screen {
        case .root:
            let viewController = viewControllerFactory.getViewController(screen: screen, navigator: self)
            navigateOnCurrentNavigationStack(viewController: viewController, animated: true)
        }
    }

    func navigateToBetshopMap() {
        let betshopMapNavigator = makeBetshopMapNavigator()
        betshopMapNavigator.navigate(to: .betshopsMap, animated: true)
        let betshopMapRootViewController = BaseViewController()
        let betshopMapRootNavigationController = betshopMapNavigator.getRootNavigationController()
        betshopMapRootViewController.embedViewController(viewController: betshopMapRootNavigationController)
        navigateOnCurrentNavigationStack(viewController: betshopMapRootViewController, animated: false)
    }
}
