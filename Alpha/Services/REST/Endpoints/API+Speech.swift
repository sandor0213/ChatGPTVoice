//
//  Speech+Authorization.swift
//  ChildQuestionApp
//
//  Created by alex on 08.02.2023.
//

import Moya

extension API {
    enum Speech {
        case questions(model: QuestionRequestModel)
        case timings(model: TimingRequestModel)
    }
}

extension API.Speech: TargetType {
    var baseURL: URL {
        return URL(string: APIConstants.baseURLPath)!
    }
    
    var path: String {
        switch self {
        case .questions:
            return "questions"
        case .timings:
            return "request_timings"
        }
    }
    
    var method: Method {
        switch self {
        case .questions, .timings:
            return .post
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .questions(let model):
            return .requestParameters(parameters: model.dict ?? [:], encoding: JSONEncoding.default)
        case .timings(let model):
            return .requestParameters(parameters: model.dict ?? [:], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .questions, .timings:
            if let access = UserDefaults.standard.string(forKey: Constants.authorizationTokenKey), !access.isEmpty {
                return ["Authorization": "\(access)"]
            } else {
                return [:]
            }
        }
    }
}

extension NetworkManager {
    enum Speech {
        static var provider = MoyaProvider<API.Speech>(plugins: [NetworkLoggerPlugin()])
        
        static func questions(model: QuestionRequestModel, completion: @escaping (Result<AnswerApiModel, Error>) -> Void) {
            NetworkManager.request(provider: NetworkManager.Speech.provider, target: .questions(model: model), completion: completion)
        }
        
        static func timings(model: TimingRequestModel, completion: @escaping (Result<Response, Error>) -> Void) {
            NetworkManager.requestNoData(provider: NetworkManager.Speech.provider, target: .timings(model: model), completion: completion)
        }
    }
}
