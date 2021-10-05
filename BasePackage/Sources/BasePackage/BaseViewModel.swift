//
//  File.swift
//  
//
//  Created by Josip Hranić on 22.09.2021..
//

import Foundation

public protocol BaseViewModel {
    
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
