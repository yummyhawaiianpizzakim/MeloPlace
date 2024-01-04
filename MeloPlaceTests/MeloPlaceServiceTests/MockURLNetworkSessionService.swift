//
//  MockURLNetworkSessionService.swift
//  MeloPlaceTests
//
//  Created by 김요한 on 2023/12/16.
//

import RxSwift
import Alamofire
@testable import MeloPlace

final class MockURLNetworkSessionService: URLNetworkSessionServiceProtocol {
    func request<T>(_ urlConvertible: Alamofire.URLRequestConvertible) -> RxSwift.Single<T> where T : Decodable, T : Encodable {
        <#code#>
    }
    
    func get<T: Codable>(dto: T.Type, url: String, paramethers: [String: String], headers: HTTPHeaders) -> Single<T> {
        return self.request(with: dto, url: url, method: .get, paramethers: paramethers, headers: headers)
    }
    
    private func request<T: Codable>(with dto: T.Type, url: String, method: HTTPMethod, paramethers: [String: String], headers: HTTPHeaders) -> Single<T> {
        return Single.create { single in
            AF.request(url,
                       method: method,
                       parameters: paramethers,
                       headers: headers
            )
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let dto):
                    single(.success(dto))
                    return
                case .failure(let error):
                    print("dto: \(error)")
                    single(.failure(error))
                    return
                }
            }
            
            return Disposables.create()
        }
    }
}
