//
//  File.swift
//  
//
//  Created by Josip Hranić on 28.09.2021..
//

import Foundation
import RxSwift
import Reachability
import RxReachability

class ReachabilitySubscription {

    private let disposeBag = DisposeBag()
    private var subscription: Observable<()> = .empty()
    private var reachability: Reachability?
    private weak var reachabilityService: ReachabilityService?
    
    init(reachabilityService: ReachabilityService) {
        self.reachabilityService = reachabilityService
        try? reachability = Reachability()
        try? reachability?.startNotifier()
        makeSubscription()
    }
}

// MARK: - Subscription
extension ReachabilitySubscription: Subscription {

    func getSubscription() -> Observable<()> {
        subscription
    }
}

// MARK: Private methods
private extension ReachabilitySubscription {

    func makeSubscription() {
        subscription = Reachability
            .rx
            .status
            .map { [unowned self] status in
                switch status {
                case .none, .unavailable:
                    reachabilityService?.update(isConnected: false)
                case .wifi, .cellular:
                    reachabilityService?.update(isConnected: true)
                }
            }
            .do(onDispose: { [unowned self] in
                reachability?.stopNotifier()
            })
            .map { _ in () }
    }
}
