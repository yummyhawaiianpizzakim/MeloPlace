//
//  URLNetworkSessionService.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/12/16.
//

import Foundation
import Alamofire
import RxSwift

enum URLSessionAPIError: Error {
    case invalidURLError
    case bodyEncodeError
    case noResponseError
    case invalidStatusCodeError
}

enum SpotifyConfiguration {
    case base
    case token
    case searchMusic
    case userProfile
    
    var path: String {
        switch self {
        case .base:
            return "https://api.spotify.com"
        case .token:
            return "/api/token"
        case .searchMusic:
            return "/v1/search"
        case .userProfile:
            return "/v1/me"
        }
    }
}

enum SpotifyHeader {
    case base
    case authorization(token: String)
    
    var path: [String: String] {
        switch self {
        case .base:
            return ["Accept":"application/json",
                    "Content-Type":"application/json"]
        case .authorization(token: let token):
            return ["Authorization":"Bearer \(token)"]
        }
    }
}

enum SpotifyParameter {
    case query(query: String)
    case type(type: String)
    
    var path: [String: String] {
        switch self {
        case .query(query: let query):
            return ["q": query]
        case .type(type: let type):
            return ["type": type]
        }
    }
}

protocol URLNetworkSessionServiceProtocol: AnyObject {
    func get<T: Codable>(dto: T.Type, url: String, paramethers: [String: String], headers: HTTPHeaders) -> Single<T>
}

final class URLNetworkSessionService: URLNetworkSessionServiceProtocol {
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
    
    private func request<T: Codable>(with data: T, url: String, method: HTTPMethod, paramethers: [String: String], headers: HTTPHeaders) -> Single<T> {
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
