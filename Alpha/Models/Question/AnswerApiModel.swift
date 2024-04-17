//
//  AnswerApiModel.swift
//  ChildQuestionApp
//
//  Created by alex on 08.02.2023.
//

import Foundation

struct AnswerApiModel: Decodable {
    let question: QuestionModel?
}

struct QuestionModel: Decodable {
    let id, age: Int?
    let createdAt: String?
    let response: ResponseModel?
    let text, updatedAt: String?
    let userID: Int?

    enum CodingKeys: String, CodingKey {
        case id, age
        case createdAt = "created_at"
        case response, text
        case updatedAt = "updated_at"
        case userID = "user_id"
    }
}

struct ResponseModel: Decodable {
    let id: Int?
    let createdAt: String?
    let questionID: Int?
    let text, updatedAt: String?
    let userID: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case questionID = "question_id"
        case text
        case updatedAt = "updated_at"
        case userID = "user_id"
    }
}
