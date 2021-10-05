//
//  File.swift
//  
//
//  Created by Josip Hranić on 28.09.2021..
//

import Foundation
import RxSwift
import RxRelay

public enum SubscriptionsState {
    case noSubscriptions
    case sessionActiveSubscriptions
}

public final class SubscriptionsContainer {

    private let subscriptionsFactory = SubscriptionsFactory(services: Services())
    private let appStateRelay = PublishRelay<SubscriptionsState>()
    private let disposeBag = DisposeBag()
    private var subscriptions: [Subscription] = []
    private var subscriptionsDisposeBag = DisposeBag()

    public init() {
        setup()
    }
}

// MARK: - Public methods
public extension SubscriptionsContainer {

    func update(state: SubscriptionsState) {
        appStateRelay.accept(state)
    }
}

// MARK: - Private methods
private extension SubscriptionsContainer {

    func setup() {
        appStateRelay
            .asObservable()
            .do(onNext: { [unowned self] _ in
                subscriptionsDisposeBag = DisposeBag()
            })
            .map { [unowned self] appState -> [Subscription] in
                switch appState {
                case .noSubscriptions:
                    subscriptions = subscriptionsFactory.noSessionSubscriptions()
                case .sessionActiveSubscriptions:
                    subscriptions = subscriptionsFactory.sessionSubscriptions()
                }
                return subscriptions
            }
            .subscribe(onNext: { [unowned self] subscriptions in
                subscriptions.forEach {
                    $0.getSubscription()
                        .subscribe()
                        .disposed(by: subscriptionsDisposeBag)
                }
            })
            .disposed(by: disposeBag)
    }
}

