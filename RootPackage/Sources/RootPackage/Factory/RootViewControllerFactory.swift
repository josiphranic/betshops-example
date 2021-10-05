//
//  File.swift
//  
//
//  Created by Josip Hranić on 21.09.2021..
//

import UIKit
import BasePackage

class RootViewControllerFactory: BaseViewControllerFactory {

    private let viewModelFactory: RootViewModelFactory

    required init(viewModelFactory: RootViewModelFactory) {
        self.viewModelFactory = viewModelFactory
    }

    func getViewController(screen: RootScreen, navigator: RootNavigator) -> UIViewController {
        switch screen {
        case .root:
            let viewModel = viewModelFactory.getRootViewModel(navigator: navigator)
            return RootViewController(viewModel: viewModel)
        }
    }
}
