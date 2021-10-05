//
//  File.swift
//  
//
//  Created by Josip Hranić on 28.09.2021..
//

import Foundation
import RxSwift
import RxRelay

public class ReachabilityService {
    
    private let isConnectedRelay = PublishRelay<Bool>()
    static let shared = ReachabilityService()
    
    private init() {
        
    }
}

// MARK: - Public properties
public extension ReachabilityService {
    
    var isConnected: Observable<Bool> {
        isConnectedRelay
            .asObservable()
            .distinctUntilChanged()
    }
}

// MARK: - Public methods
extension ReachabilityService {
    
    func update(isConnected: Bool) {
        isConnectedRelay.accept(isConnected)
    }
}
