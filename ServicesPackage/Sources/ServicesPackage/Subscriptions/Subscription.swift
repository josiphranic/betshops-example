//
//  File.swift
//  
//
//  Created by Josip Hranić on 28.09.2021..
//

import Foundation
import RxSwift

protocol Subscription {

    func getSubscription() -> Observable<()>
}
