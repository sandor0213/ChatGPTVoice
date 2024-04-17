//
//  NetworkManager.swift
//  ChildQuestionApp
//
//  Created by alex on 08.02.2023.
//

import Moya

final class NetworkManager {
    public static func request<T: Decodable, TType: TargetType>(provider: MoyaProvider<TType>, target: TType, completion: @escaping (Result<T, Error>) -> Void) {
        provider.request(target) { result in
            switch result {
            case let .success(response):
                do {
                    let results = try JSONDecoder().decode(T.self, from: response.data)
                    if let token = (response.response)?.allHeaderFields["Authorization"] as? String {
                        UserDefaults.standard.set(token, forKey: Constants.authorizationTokenKey)
                    }
                    completion(.success(results))
                } catch let error {
                    completion(.failure(error))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    public static func requestData<TType: TargetType>(provider: MoyaProvider<TType>, target: TType, completion: @escaping (Result<Data, Error>) -> Void) {
        provider.request(target) { result in
            switch result {
            case let .success(response):
                completion(.success(response.data))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    public static func requestNoData<TType: TargetType>(provider: MoyaProvider<TType>, target: TType, completion: @escaping (Result<Response, Error>) -> Void) {
        provider.request(target) { result in
            switch result {
            case let .success(response):
                completion(.success(response))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
