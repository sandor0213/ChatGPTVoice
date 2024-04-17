//
//  ValidationService.swift
//  ChildQuestionApp
//
//  Created by alex on 07.02.2023.
//

import UIKit

final class ValidationService {
    static func isValidEmail(_ email: String, isSignIn: Bool = false) -> String? {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email) ? nil : "Please enter a valid email"
    }

    static func isValidPassword(_ password: String) -> String? {
        password.count > 5 ? nil : "Your password must be at least 6 characters"
    }
}
