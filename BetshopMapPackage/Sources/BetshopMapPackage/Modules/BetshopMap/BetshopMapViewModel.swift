//
//  File.swift
//  
//
//  Created by Josip Hranić on 22.09.2021..
//

import Foundation
import CoreLocation
import BasePackage
import ServicesPackage
import RxSwift
import RxRelay
import MapKit
import RxFeedback


enum BetshopInfoStatus: Equatable {
    case hidden
    case visible(BetshopMapModel)
    
    static func == (lhs: BetshopInfoStatus, rhs: BetshopInfoStatus) -> Bool {
        switch (lhs, rhs) {
        case (.hidden, .hidden):
            return true
        case (.hidden, .visible(_)), (visible(_), .hidden):
            return false
        case let (.visible(lhsBetshop), .visible(rhsBetshop)):
            return lhsBetshop.id == rhsBetshop.id
        }
    }
}

struct BetshopMapModel: Hashable, Clusterable {
    
    let coordinates: CLLocationCoordinate2D
    let id: Int
    let name: String
    let address: String
    let city: String
    let county: String
    
    static func == (lhs: BetshopMapModel, rhs: BetshopMapModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var relativePoint: Point {
        .init(x: Float(180 + coordinates.latitude) / 360,
              y: Float(90 - coordinates.longitude) / 180)
    }
}

struct BetshopMapViewModelInput {

    let visibleRegionAndDistanceThreshold: Observable<(CLLocationCoordinate2D, CLLocationCoordinate2D, Float)>
    let selectedShop: Observable<BetshopMapModel>
    let routeTap: Observable<BetshopMapModel>
    let closeBetshopInfoTap: Observable<()>
}

struct BetshopMapViewModelOutput {

    let betshopClusters: Observable<[[BetshopMapModel]]>
    let userLocation: Observable<CLLocationCoordinate2D>
    let betshopInfo: Observable<BetshopInfoStatus>
    let betshopLoading: Observable<Bool>
}

private enum Event {
    case selectedShop(BetshopMapModel)
    case closeBetshopInfo
    case userLocationUpdate(CLLocationCoordinate2D)
    case betshopsClustered([[BetshopMapModel]])
    case betshopLoadingUpdate(Bool)
}

private struct State {
    
    fileprivate typealias FeedbackLoop = (ObservableSchedulerContext<State>) -> Observable<Event>

    var distanceThreshold: Float?
    var betshopClusters: [[BetshopMapModel]]?
    var userLocation: CLLocationCoordinate2D?
    var betshopInfoStatus: BetshopInfoStatus
    var betshopsLoading: Bool

    func reset() -> State {
        .init(distanceThreshold: nil,
              betshopClusters: nil,
              userLocation: nil,
              betshopInfoStatus: betshopInfoStatus,
              betshopsLoading: betshopsLoading)
    }

    static func initial() -> State {
        .init(distanceThreshold: nil,
              betshopClusters: nil,
              userLocation: nil,
              betshopInfoStatus: .hidden,
              betshopsLoading: false)
    }
    
    static func reduce(state: State, event: Event) -> State {
        switch event {
        case .selectedShop(let betshop):
            var newState = state.reset()
            newState.betshopInfoStatus = .visible(betshop)
            return newState
        case .closeBetshopInfo:
            var newState = state.reset()
            newState.betshopInfoStatus = .hidden
            return newState
        case .userLocationUpdate(let location):
            var newState = state.reset()
            newState.userLocation = location
            return newState
        case .betshopsClustered(let betshopClusters):
            var newState = state.reset()
            newState.betshopClusters = betshopClusters
            return newState
        case .betshopLoadingUpdate(let isLoading):
            var newState = state.reset()
            newState.betshopsLoading = isLoading
            return newState
        }
    }
}

class BetshopMapViewModel: BaseViewModel {

    private let betshopMapNavigator: BetshopMapNavigator
    private let apiClientService: APIClientService
    private let locationService: LocationService
    private let clusteringService: ClusteringService
    private let serialScheduler = SerialDispatchQueueScheduler(qos: .userInteractive)
    
    init(navigator: BetshopMapNavigator,
         apiClientService: APIClientService,
         locationService: LocationService,
         clusteringService: ClusteringService) {
        self.betshopMapNavigator = navigator
        self.apiClientService = apiClientService
        self.locationService = locationService
        self.clusteringService = clusteringService
    }

    func transform(input: BetshopMapViewModelInput) -> BetshopMapViewModelOutput {
        let state = system(input: input)
            .skip { $0.userLocation == nil }
            .share(replay: 1)
        
        let output = BetshopMapViewModelOutput(betshopClusters: state.compactMap { $0.betshopClusters },
                                               userLocation: state.compactMap { $0.userLocation },
                                               betshopInfo: state.map { $0.betshopInfoStatus }.distinctUntilChanged(),
                                               betshopLoading: state.map { $0.betshopsLoading }.distinctUntilChanged())

        return output
    }
}

// MARK: - Private methods
private extension BetshopMapViewModel {
    
    func system(input: BetshopMapViewModelInput) -> Observable<State> {
        let routeTapFeedbackLoop: State.FeedbackLoop = { _ in
            input
                .routeTap
                .do(onNext: { [unowned self] in
                    openMapsFor(betshop: $0)
                })
                .flatMapLatest { _ in Observable.empty() }
        }
        let betshopInfoFeedbackLoop: State.FeedbackLoop = { [unowned self] _ in
            Observable.merge(input.closeBetshopInfoTap.map { .closeBetshopInfo },
                             input.selectedShop.map { .selectedShop($0) })
                .throttle(.milliseconds(500), scheduler: serialScheduler)
        }
        let userLocationFeedbackLoop: State.FeedbackLoop = { [unowned self] _ in
            locationService
                .location
                .map { .userLocationUpdate($0.coordinate) }
                .timeout(.seconds(4), scheduler: SerialDispatchQueueScheduler(qos: .userInitiated))
                .catchAndReturn(.userLocationUpdate(CLLocationCoordinate2D(latitude: 48.137154, longitude: 11.576124)))
                .take(1)
        }
        let betshopLoadingFeedbackLoop: State.FeedbackLoop = { [unowned self] _ in
            apiClientService
                .betshopsLoading
                .distinctUntilChanged()
                .map { .betshopLoadingUpdate($0) }
        }
        let betshopsUpdateFeedbackLoop: State.FeedbackLoop = { [unowned self] state in
            input
                .visibleRegionAndDistanceThreshold
                .throttle(.milliseconds(500), scheduler: serialScheduler)
                .withLatestFrom(state.map { $0.betshopsLoading }, resultSelector: { ($0, $1) })
                .filter { !$0.1 }
                .map { $0.0 }
                .map { (BetshopsBoundingBox(topRightCoordinate: $0.0, bottomLeftCoordinate: $0.1), $0.2) }
                .flatMapLatest { [unowned self] boundingBox, distanceThreshold in
                    apiClientService
                        .loadBetshops(boundingBox: boundingBox)
                        .map { ($0, distanceThreshold) }
                        .catch { _ in .empty() } }
                .map { ($0.0.betshops.map { [unowned self] in mapBetshopToBetshopMapModel($0) }, $0.1) }
                .flatMap { [unowned self] in clusteringService.greedyCluster(clusterables: $0.0, thresholdDistance: $0.1) }
                .map { $0.map { $0.compactMap { $0 as? BetshopMapModel } } }
                .map { .betshopsClustered($0)  }
        }

        return Observable.system(initialState: State.initial(),
                                 reduce: State.reduce,
                                 scheduler: serialScheduler,
                                 feedback: [routeTapFeedbackLoop,
                                            betshopInfoFeedbackLoop,
                                            userLocationFeedbackLoop,
                                            betshopLoadingFeedbackLoop,
                                            betshopsUpdateFeedbackLoop])
    }
    
    func mapBetshopToBetshopMapModel(_ betshop: Betshop) -> BetshopMapModel {
        BetshopMapModel(coordinates: betshop.location.coreLocationCoordinate,
                        id: betshop.id,
                        name: betshop.name,
                        address: betshop.address,
                        city: betshop.city,
                        county: betshop.county)
    }

    func openMapsFor(betshop: BetshopMapModel) {
        let regionDistance = 10000
        let regionSpan = MKCoordinateRegion(center: betshop.coordinates,
                                            latitudinalMeters: CLLocationDistance(regionDistance),
                                            longitudinalMeters: CLLocationDistance(regionDistance))
        let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                       MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
        let placemark = MKPlacemark(coordinate: betshop.coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(betshop.name)"
        mapItem.openInMaps(launchOptions: options)
    }
}

extension BetshopLocation {
    
    var coreLocationCoordinate: CLLocationCoordinate2D {
        .init(latitude: latitude, longitude: longitude)
    }
}
