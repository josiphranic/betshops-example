//
//  File.swift
//  
//
//  Created by Josip Hranić on 23.09.2021..
//

import Foundation
import RxAlamofire
import RxSwift
import RxRelay

public enum APIClientError: Error {
    case invalidStatusCode(code: Int)
    case jsonDecodeError
    
    public var description: String {
        switch self {
        case .invalidStatusCode(let code):
            return "Invalid status code \(code)."
        case .jsonDecodeError:
            return "JSON decode error."
        }
    }
}

public class APIClientService {

    private let baseUrl = "https://interview.superology.dev"
    private let apiUrl = "/betshops"
    private let boundingBoxParameterKey = "boundingBox"
    private let betshopsLoadingRelay = BehaviorRelay<Bool>(value: false)
    private let serialScheduler = SerialDispatchQueueScheduler(qos: .userInteractive)
    static let shared = APIClientService()
    
    private init() {

    }
}

// MARK: - Public methods
public extension APIClientService {

    func loadBetshops(boundingBox: BetshopsBoundingBox) -> Observable<Betshops> {
        betshopsLoadingRelay.accept(true)
        return RxAlamofire
            .requestData(.get,
                         "\(baseUrl)\(apiUrl)",
                         parameters: [boundingBoxParameterKey: boundingBox.asUrlParameterValue])
            .observe(on: serialScheduler)
            .flatMap { [weak self] response , data -> Observable<Betshops> in
                guard (200..<300).contains(response.statusCode) else {
                    self?.betshopsLoadingRelay.accept(false)
                    return .error(APIClientError.invalidStatusCode(code: response.statusCode))
                }
                guard let betshops: Betshops = self?.decodeJSON(data) else {
                    self?.betshopsLoadingRelay.accept(false)
                    return .error(APIClientError.jsonDecodeError)
                }
                
                self?.betshopsLoadingRelay.accept(false)
                return .just(betshops)
            }
    }
}

// MARK: - Public properties
public extension APIClientService {

    var betshopsLoading: Observable<Bool> {
        betshopsLoadingRelay.asObservable()
    }
}

// MARK: - Private methods
private extension APIClientService {

    func decodeJSON<T: Decodable>(_ data: Data) -> T? {
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch let jsonError {
            print("#Error: \(jsonError.localizedDescription)")
            return nil
        }
    }
}
