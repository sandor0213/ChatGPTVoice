//
//  AuthApiModel.swift
//  ChildQuestionApp
//
//  Created by alex on 08.02.2023.
//

import Foundation

struct AuthApiModel: Decodable {
    let id: Int?
    let email: String?
    let createdAt: String?
    let updatedAt: String?
    let jti: String?
    let errors: ErrorModel?
    
    private enum CodingKeys: String, CodingKey {
        case id, email, jti
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case errors
    }
}

struct ErrorModel: Decodable {
    let email: [String]?
    let password: [String]?
    let error: [String]?
}
