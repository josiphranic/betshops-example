//
//  File.swift
//  
//
//  Created by Josip Hranić on 22.09.2021..
//

import UIKit

public protocol BaseViewControllerFactory {
    
    associatedtype ViewModelFactory
    associatedtype Screen
    associatedtype Navigator
    
    init(viewModelFactory: ViewModelFactory)

    func getViewController(screen: Screen, navigator: Navigator) -> UIViewController
}
