//
//  AuthorizationViewController.swift
//  ChildQuestionApp
//
//  Created by alex on 07.02.2023.
//

import UIKit

class AuthorizationViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        hideKeyboardWhenTappedAround()
    }
    
    func isValidInputs() -> Bool {
        var errorText = ""
        if let emailError = ValidationService.isValidEmail(emailTextField.text ?? "") {
            errorText = emailError
        }
        if let passwordError = ValidationService.isValidPassword(passwordTextField.text ?? "") {
            errorText += errorText.isEmpty ? "\(passwordError)" : "\n\(passwordError)"
        }
        
        if !errorText.isEmpty {
            presentAlert(withTitle: errorText)
        }
        return errorText.isEmpty
    }
}
