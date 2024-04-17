//
//  QuestionRequestModel.swift
//  ChildQuestionApp
//
//  Created by alex on 08.02.2023.
//

import Foundation

struct QuestionRequestModel: Encodable {
    let question: Question?
}

struct Question: Encodable {
    let text: String?
    let age: Int?
    let clientInfo: String?

    enum CodingKeys: String, CodingKey {
        case text, age
        case clientInfo = "client_info"
    }
}
