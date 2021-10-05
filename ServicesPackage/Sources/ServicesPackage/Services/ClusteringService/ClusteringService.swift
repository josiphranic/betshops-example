//
//  File.swift
//  
//
//  Created by Josip Hranić on 29.09.2021..
//

import Foundation
import RxSwift
import RxRelay

public struct Point {
    
    let x: Float
    let y: Float
    
    public init(x: Float,
                y: Float) {
        self.x = x
        self.y = y
    }

    func distance(to point: Point) -> Float {
        let xDistance = x - point.x
        let yDistance = y - point.y
        
        return sqrt(xDistance * xDistance + yDistance * yDistance)
    }
}

public protocol Clusterable {
    
    var relativePoint: Point { get }
}

private struct Cluster {
    
    let members: [Clusterable]

    var relativePoint: Point {
        .init(x: members.map { $0.relativePoint.x }.reduce(0, +) / Float(members.count),
              y: members.map { $0.relativePoint.y }.reduce(0, +) / Float(members.count))
    }
    
    func filterInRange(clusters: [Cluster], thresholdDistance: Float) -> (inRange: [Cluster], outsideRange: [Cluster]) {
        let thisRelativePoint = relativePoint
        var inRange: [Cluster] = []
        var outsideRange: [Cluster] = []
        clusters.forEach { Self.inRange(of: thisRelativePoint, cluster: $0, thresholdDistance: thresholdDistance) ? inRange.append($0) : outsideRange.append($0) }
        
        return (inRange, outsideRange)
    }
    
    static func inRange(of relativePoint: Point, cluster: Cluster, thresholdDistance: Float) -> Bool {
        let clusterRelativePoint = cluster.relativePoint
        let xDistance = abs(relativePoint.x - clusterRelativePoint.x)
        guard xDistance <= thresholdDistance else {
            return false
        }
        let yDistance = abs(relativePoint.y - clusterRelativePoint.y)
        guard yDistance <= thresholdDistance else {
            return false
        }
        
        return true
    }
}

public class ClusteringService {
    
    private let serialScheduler = SerialDispatchQueueScheduler(qos: .userInteractive)
    static let shared = ClusteringService()
    
    private init() {
        
    }
}

// MARK: - Public methods
public extension ClusteringService {
    
    func greedyCluster(clusterables: [Clusterable],
                       thresholdDistance: Float) -> Observable<[[Clusterable]]> {
        return cluster(clusterables, thresholdDistance: thresholdDistance)
            .map { $0.map { $0.members } }
    }
}

// MARK: - Private methods
private extension ClusteringService {

    func cluster(_ clusterables: [Clusterable], thresholdDistance: Float) -> Observable<[Cluster]> {
        .create { observer in
            var remainingClusters = clusterables.map { Cluster(members: [$0]) }
            var result: [Cluster] = []
            while let randomCluster = remainingClusters.randomElement() {
                let (inRangeClusters, outsideRangeClusters) = randomCluster.filterInRange(clusters: remainingClusters, thresholdDistance: thresholdDistance)
                result.append(inRangeClusters.merge())
                remainingClusters = outsideRangeClusters
            }
            observer.onNext(result)
            observer.onCompleted()
            return Disposables.create()
        }
        .subscribe(on: serialScheduler)
    }
}

private extension Array where Element == Cluster {
    
    func merge() -> Cluster {
        Cluster(members: map { $0.members }.flatMap { $0 })
    }
}
