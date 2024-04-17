//
//  API+Authorization.swift
//  ChildQuestionApp
//
//  Created by alex on 08.02.2023.
//

import Moya

extension API {
    enum Authorization {
        case signUp(model: AuthRequestModel)
        case signIn(model: AuthRequestModel)
        case signOut
    }
}

extension API.Authorization: TargetType {
    var baseURL: URL {
        return URL(string: APIConstants.baseURLPath)!
    }
    
    var path: String {
        switch self {
        case .signUp:
            return "users"
        case .signIn:
            return "users/sign_in"
        case .signOut:
            return "users/sign_out"
        }
    }
    
    var method: Method {
        switch self {
        case .signUp, .signIn:
            return .post
        case .signOut:
            return .delete
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .signUp(let model), .signIn(let model):
            return .requestParameters(parameters: model.dict ?? [:], encoding: JSONEncoding.default)
        case .signOut:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .signUp, .signIn:
            return [:]
        case .signOut:
            if let access = UserDefaults.standard.string(forKey: Constants.authorizationTokenKey), !access.isEmpty {
                return ["Authorization": "\(access)"]
            } else {
                return [:]
            }
        }
    }
}

extension NetworkManager {
    enum Authorization {
        static var provider = MoyaProvider<API.Authorization>(plugins: [NetworkLoggerPlugin()])
        
        static func signUp(model: AuthRequestModel, completion: @escaping (Result<AuthApiModel, Error>) -> Void) {
            NetworkManager.request(provider: NetworkManager.Authorization.provider, target: .signUp(model: model), completion: completion)
        }
        
        static func signIn(model: AuthRequestModel, completion: @escaping (Result<AuthApiModel, Error>) -> Void) {
            NetworkManager.request(provider: NetworkManager.Authorization.provider, target: .signIn(model: model), completion: completion)
        }
        
        static func signOut(completion: @escaping (Result<Response, Error>) -> Void) {
            NetworkManager.requestNoData(provider: NetworkManager.Authorization.provider, target: .signOut, completion: completion)
        }
    }
}
