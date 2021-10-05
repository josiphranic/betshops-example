//
//  File.swift
//  
//
//  Created by Josip Hranić on 24.09.2021..
//

import UIKit
import MapKit

class CloverAnnotationView: MKAnnotationView {
    
    static let identifier = String(describing: CloverAnnotationView.self)
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        image = .blueCloverPin?.resize(to: .init(width: 20, height: 30))
    }
}

// MARK: - Public methods
extension CloverAnnotationView {
    
    func update(selected: Bool) {
        image = selected ? .greenCloverPin?.resize(to: .init(width: 30, height: 45)) : .blueCloverPin?.resize(to: .init(width: 20, height: 30))
    }
}

// MARK: - Private methods
private extension CloverAnnotationView {

    func setupView() {
        layer.anchorPoint = .init(x: 0.5, y: 1)
    }
}
