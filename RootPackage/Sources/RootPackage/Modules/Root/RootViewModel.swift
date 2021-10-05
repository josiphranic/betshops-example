//
//  File.swift
//  
//
//  Created by Josip Hranić on 21.09.2021..
//

import Foundation
import BasePackage
import ServicesPackage
import RxSwift
import RxRelay

struct RootViewModelInput {

    let anmationCompleted: Observable<()>
}

struct RootViewModelOutput {

    let networkConnectionAvailable: Observable<Bool>
}

class RootViewModel: BaseViewModel {

    private let reachabilityService: ReachabilityService
    private let rootNavigator: RootNavigator
    private let subscriptionContainer = SubscriptionsContainer()
    private var disposeBag = DisposeBag()
    
    init(rootNavigator: RootNavigator,
         reachabilityService: ReachabilityService) {
        self.reachabilityService = reachabilityService
        self.rootNavigator = rootNavigator
    }
    
    func transform(input: RootViewModelInput) -> RootViewModelOutput {
        disposeBag = DisposeBag()
        subscriptionContainer.update(state: .noSubscriptions)
        input
            .anmationCompleted
            .subscribe(onNext: { [unowned self] in
                subscriptionContainer.update(state: .sessionActiveSubscriptions)
                rootNavigator.navigateToBetshopMap()
            })
            .disposed(by: disposeBag)
        
        return RootViewModelOutput(networkConnectionAvailable: reachabilityService.isConnected)
    }
}
