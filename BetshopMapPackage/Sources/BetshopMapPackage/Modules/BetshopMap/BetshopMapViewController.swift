//
//  File.swift
//  
//
//  Created by Josip Hranić on 22.09.2021..
//

import UIKit
import BasePackage
import CommonUIPackage
import MapKit
import SnapKit
import RxRelay
import RxSwift

class BetshopMapViewController: BaseViewController {
    
    private let mapView = MKMapView()
    private let betshopInfoView = BetshopInfoView()
    private let activityIndicatorView = UIActivityIndicatorView()
    private let visibleRegionAndDistanceThresholdRelay = PublishRelay<(CLLocationCoordinate2D, CLLocationCoordinate2D, Float)>()
    private let selectedShopRelay = PublishRelay<BetshopMapModel>()
    private let viewModel: BetshopMapViewModel
    private var selectedCloverAnnotationView: CloverAnnotationView?
    
    init(viewModel: BetshopMapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        addSubviews()
        setupMapView()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func bindViewModel() {
        let input = BetshopMapViewModelInput(visibleRegionAndDistanceThreshold: visibleRegionAndDistanceThresholdRelay.asObservable(),
                                             selectedShop: selectedShopRelay.asObservable(),
                                             routeTap: betshopInfoView.routeTap,
                                             closeBetshopInfoTap: betshopInfoView.closeTap)
        let output = viewModel.transform(input: input)
        output
            .betshopClusters
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in
                let (oldClusterAnnotations, oldCloverAnnotations) = getOldAnnotations(annotations: mapView.annotations)
                let (newClusterAnnotations, newCloverAnnotations) = getNewAnnotations(betshops: $0)
                let toAddCloverAnnotations = Array(Set(newCloverAnnotations).subtracting(Set(oldCloverAnnotations)))
                let toRemoveCloverAnnotations = Array(Set(oldCloverAnnotations).subtracting(Set(newCloverAnnotations)))
                let toAddClusterAnnotations = Array(Set(newClusterAnnotations).subtracting(Set(oldClusterAnnotations)))
                let toRemoveClusterAnnotations = Array(Set(oldClusterAnnotations).subtracting(Set(newClusterAnnotations)))
                prepareCloverDivergeAnimations(toAddCloverAnnotations: toAddCloverAnnotations, toRemoveClusterAnnotations: toRemoveClusterAnnotations)
                prepareClusterReplaceAnimations(toAddClusterAnnotations: toAddClusterAnnotations, toRemoveClusterAnnotations: toRemoveClusterAnnotations)
                mapView.removeAnnotations(toRemoveCloverAnnotations)
                mapView.removeAnnotations(toRemoveClusterAnnotations)
                mapView.addAnnotations(toAddCloverAnnotations)
                mapView.addAnnotations(toAddClusterAnnotations)
            })
            .disposed(by: disposeBag)
        output
            .userLocation
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in mapView.centerToLocation(location: $0) })
            .disposed(by: disposeBag)
        output
            .betshopInfo
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in updateBetshopInfoView($0) })
            .disposed(by: disposeBag)
        output
            .betshopLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] in $0 ? activityIndicatorView.startAnimating() : activityIndicatorView.stopAnimating() })
            .disposed(by: disposeBag)
    }
}

// MARK: - MKMapViewDelegate
extension BetshopMapViewController: MKMapViewDelegate {
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        let thresholdDistance = getAnnotationRelativeSize()
        visibleRegionAndDistanceThresholdRelay.accept((mapView.getTopRightCoordinate(), mapView.getBottomLeftCoordinate(), thresholdDistance))
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let cloverAnnotation = view.annotation as? CloverAnnotation else {
            return
        }
        selectedCloverAnnotationView?.update(selected: false)
        selectedCloverAnnotationView = view as? CloverAnnotationView
        selectedCloverAnnotationView?.update(selected: true)
        selectedShopRelay.accept(cloverAnnotation.mapModel)
        mapView.deselectAnnotation(cloverAnnotation, animated: false)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let cloverAnnotation = annotation as? CloverAnnotation,
           let cloverAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: CloverAnnotationView.identifier) as? CloverAnnotationView {
            cloverAnnotationView.annotation = cloverAnnotation
            return cloverAnnotationView
        }
        if let clusterAnnotation = annotation as? ClusterAnnotation,
           let clusterAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: ClusterAnnotationView.identifier) as? ClusterAnnotationView {
            clusterAnnotationView.annotation = clusterAnnotation
            return clusterAnnotationView
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        views.forEach {
            if let cloverAnnotationView = $0 as? CloverAnnotationView,
               let cloverAnnotation = cloverAnnotationView.annotation as? CloverAnnotation,
               let previousClusterFrame = cloverAnnotation.previousClusterFrame {
                let endFrame = cloverAnnotationView.frame
                cloverAnnotationView.frame = previousClusterFrame
                UIView.animate(withDuration: 0.5) {
                    cloverAnnotationView.frame = endFrame
                }
            } else if let clusterAnnotationView = $0 as? ClusterAnnotationView,
                      let clusterAnnotation = clusterAnnotationView.annotation as? ClusterAnnotation,
                      let previousClusterFrame = clusterAnnotation.previousFrame {
                let endFrame = clusterAnnotationView.frame
                clusterAnnotationView.frame = previousClusterFrame
                UIView.animate(withDuration: 0.5) {
                    clusterAnnotationView.frame = endFrame
                }
            }
        }
    }
}

// MARK: - Private methods
private extension BetshopMapViewController {

    func addSubviews() {
        view.addSubview(mapView)
        view.addSubview(betshopInfoView)
        view.addSubview(activityIndicatorView)
    }
    
    func setupMapView() {
        mapView.register(CloverAnnotationView.self, forAnnotationViewWithReuseIdentifier: CloverAnnotationView.identifier)
        mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: ClusterAnnotationView.identifier)
        mapView.mapType = .mutedStandard
        mapView.isRotateEnabled = false
        mapView.delegate = self
    }
    
    func makeConstraints() {
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        betshopInfoView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(200)
            $0.top.equalTo(view.snp.bottom)
        }
        activityIndicatorView.snp.makeConstraints {
            $0.top.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.width.height.equalTo(50)
        }
    }
    
    func updateBetshopInfoView(_ betshopInfoStatus: BetshopInfoStatus) {
        switch betshopInfoStatus {
        case .hidden:
            selectedCloverAnnotationView?.update(selected: false)
            UIView.animate(withDuration: 0.5) { [unowned self] in
                betshopInfoView.snp.updateConstraints {
                    $0.top.equalTo(view.snp.bottom).offset(0)
                }
                view.layoutSubviews()
            }
        case .visible(let betshop):
            betshopInfoView.update(betshop: betshop)
            UIView.animate(withDuration: 0.5) { [unowned self] in
                betshopInfoView.snp.updateConstraints {
                    $0.top.equalTo(view.snp.bottom).offset(-200)
                }
                view.layoutSubviews()
            }
        }
    }

    func getAnnotationRelativeSize() -> Float {
        let mapCenterPoint = mapView.center
        let mapCenterOffsetPoint = CGPoint(x: mapCenterPoint.x + 50, y: mapCenterPoint.y + 70)
        let centerCoordinate = mapView.convert(mapCenterPoint, toCoordinateFrom: mapView)
        let centerOffsetCoordinate = mapView.convert(mapCenterOffsetPoint, toCoordinateFrom: mapView)
        let relativeCenterLatitude = Float(180 + centerCoordinate.latitude) / 360
        let relativeCenterLongitude = Float(90 - centerCoordinate.longitude) / 180
        let relativeCenterOffsetLatitude = Float(180 + centerOffsetCoordinate.latitude) / 360
        let relativeCenterOffsetLongitude = Float(90 - centerOffsetCoordinate.longitude) / 180
        let latitudeDifference = abs(relativeCenterLatitude - relativeCenterOffsetLatitude)
        let longitudeDifference = abs(relativeCenterLongitude - relativeCenterOffsetLongitude)
        let distance = sqrt(latitudeDifference * latitudeDifference + longitudeDifference * longitudeDifference)
        
        return distance
    }
    
    func getNewAnnotations(betshops: [[BetshopMapModel]]) -> (clusterAnnotations: [ClusterAnnotation],
                                                              cloverAnnotations: [CloverAnnotation]) {
        let newCloverAnnotations = betshops
            .filter { $0.count == 1 }
            .map { $0.map { CloverAnnotation(coordinate: $0.coordinates, mapModel: $0) } }
            .flatMap { $0 }
        let newClusterAnnotations = betshops
            .filter { $0.count > 1 }
            .map { ClusterAnnotation(members: $0) }
        
        return (newClusterAnnotations, newCloverAnnotations)
    }
    
    func getOldAnnotations(annotations: [MKAnnotation]) -> (clusterAnnotations: [ClusterAnnotation],
                                                            cloverAnnotations: [CloverAnnotation]) {
        let oldCloverAnnotations = mapView
            .annotations
            .compactMap { $0 as? CloverAnnotation }
        let oldClusterAnnotations = mapView
            .annotations
            .compactMap { $0 as? ClusterAnnotation }
        
        return (oldClusterAnnotations, oldCloverAnnotations)
    }
    
    func prepareCloverDivergeAnimations(toAddCloverAnnotations: [CloverAnnotation],
                                        toRemoveClusterAnnotations: [ClusterAnnotation]) {
        toAddCloverAnnotations.forEach { cloverAnnotation in
            if let previousClusterAnnotation = toRemoveClusterAnnotations.first(where: { $0.members.contains(cloverAnnotation.mapModel) }) {
                cloverAnnotation.previousClusterFrame = previousClusterAnnotation.viewFrame
            }
        }
    }
    
    func prepareClusterReplaceAnimations(toAddClusterAnnotations: [ClusterAnnotation],
                                         toRemoveClusterAnnotations: [ClusterAnnotation]) {
        toAddClusterAnnotations.forEach { toAddClusterAnnotation in
            let toAddmembers = Set(toAddClusterAnnotation.members)
            if let previousClusterAnnotation = toRemoveClusterAnnotations.first(where: { !toAddmembers.isDisjoint(with: $0.members) }) {
                toAddClusterAnnotation.previousFrame = previousClusterAnnotation.viewFrame
            }
        }
    }
}
