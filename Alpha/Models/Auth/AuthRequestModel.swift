//
//  AuthModel.swift
//  ChildQuestionApp
//
//  Created by alex on 08.02.2023.
//

import Foundation

struct AuthRequestModel: Encodable {
    let user: AuthModel
}

struct AuthModel: Encodable {
    let email: String?
    let password: String?
}
