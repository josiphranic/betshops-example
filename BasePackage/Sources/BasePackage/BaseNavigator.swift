//
//  File.swift
//  
//
//  Created by Josip Hranić on 21.09.2021..
//

import UIKit

public protocol BaseNavigator {

    associatedtype Screen

    func getRootNavigationController() -> UINavigationController
    func navigate(to screen: Screen, animated: Bool)
}

// MARK: - Public methods
public extension BaseNavigator {
    
    func navigateOnCurrentNavigationStack(viewController: UIViewController, animated: Bool) {
        getRootNavigationController().pushViewController(viewController, animated: animated)
    }
    
    func popViewController(animated: Bool) {
        getRootNavigationController().popViewController(animated: animated)
    }
    
    func navigateByReplacingNavigationStack(viewControllers: [UIViewController]) {
        getRootNavigationController().viewControllers.forEach { $0.removeFromParent() }
        getRootNavigationController().viewControllers = viewControllers
    }
}
