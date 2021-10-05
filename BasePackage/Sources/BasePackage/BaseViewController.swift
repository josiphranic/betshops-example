//
//  File.swift
//  
//
//  Created by Josip Hranić on 21.09.2021..
//

import UIKit
import RxSwift

open class BaseViewController: UIViewController {

    public var disposeBag = DisposeBag()

    open func bindViewModel() {

    }
}

// MARK: - Lifecycle methods
extension BaseViewController {

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        overrideUserInterfaceStyle = .light
        disposeBag = DisposeBag()
        bindViewModel()
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        disposeBag = DisposeBag()
    }
}

// MARK: - Public methods
public extension BaseViewController {
    
    func embedViewControllerToView(viewController: UIViewController, view: UIView) {
        addChild(viewController)
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }

    func embedViewController(viewController: UIViewController) {
        addChild(viewController)
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
    
    func topMostViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            return topController
        }
        
        return nil
    }
}
