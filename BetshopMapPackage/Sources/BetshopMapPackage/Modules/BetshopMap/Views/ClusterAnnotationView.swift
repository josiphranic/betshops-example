//
//  File.swift
//  
//
//  Created by Josip Hranić on 25.09.2021..
//

import UIKit
import MapKit

class ClusterAnnotationView: MKAnnotationView {
    
    private let clusterCountLabel = UILabel()
    static let identifier = String(describing: ClusterAnnotationView.self)
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        addSubviews()
        setupLabels()
        setupView()
        setupImage()
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        if let clusterAnntation = annotation as? ClusterAnnotation {
            clusterCountLabel.text = clusterAnntation.members.count > 99 ? "99+" : "\(clusterAnntation.members.count)"
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let clusterAnnotation = annotation as? ClusterAnnotation {
            clusterAnnotation.viewFrame = frame
        }
    }
}

// MARK: - Private methods
private extension ClusterAnnotationView {
    
    func addSubviews() {
        addSubview(clusterCountLabel)
    }
    
    func setupLabels() {
        clusterCountLabel.textColor = .white
        clusterCountLabel.textAlignment = .center
        clusterCountLabel.font = UIFont.boldSystemFont(ofSize: 14)
    }
    
    func setupImage() {
        image = .greenPin?.withTintColor(.clusterBlue).resize(to: .init(width: 30, height: 45))
    }
    
    func setupView() {
        layer.anchorPoint = .init(x: 0.5, y: 1)
    }
    
    func layout() {
        clusterCountLabel.frame = bounds
    }
}
