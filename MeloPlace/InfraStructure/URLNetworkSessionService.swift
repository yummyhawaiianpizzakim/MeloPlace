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

public protocol TargetType: URLRequestConvertible {
    var baseURL: String { get }
    var method: HTTPMethod { get }
    var header: HTTPHeaders { get }
    var path: String { get }
    var parameters: Parameters? { get }
    var encoding: ParameterEncoding { get }
}

public extension TargetType {
    func asURLRequest() throws -> URLRequest {
        var urlRequest = try URLRequest(url: self.baseURL + self.path, method: self.method)
        urlRequest.headers = self.header
        let params = self.parameters
        return try encoding.encode(urlRequest, with: params)
    }
}

protocol URLNetworkSessionServiceProtocol: AnyObject {
    func request<T: Codable>(_ urlConvertible: URLRequestConvertible) -> Single<T>
}

final class URLNetworkSessionService: URLNetworkSessionServiceProtocol {
    func request<T: Codable>(_ urlConvertible: URLRequestConvertible) -> Single<T> {
        return Single.create { single in
            AF.request(urlConvertible)
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
