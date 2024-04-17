//
//  LoginViewController.swift
//  ChildQuestionApp
//
//  Created by alex on 07.02.2023.
//

import UIKit

final class LoginViewController: AuthorizationViewController {
    
    @IBAction func signInAction(_ sender: Any) {
        guard isValidInputs() else { return }
        
        signIn()
    }
    
    @IBAction func redirectToSignUp(_ sender: Any) {
        navigationController?.pushViewController(UIStoryboard.controller(.main, type: RegistrationViewController.self, identifier: .registrationViewController), animated: true)
    }
}

private extension LoginViewController {
    func signIn() {
        NetworkManager.Authorization.signIn(model: AuthRequestModel(user: AuthModel(email: emailTextField.text, password: passwordTextField.text))) { [weak self] result in
            switch result {
            case .success(let model):
                if model.id == nil || !(model.errors?.error?.isEmpty ?? true) {
                    self?.presentAlert(withTitle: model.errors?.error?.joined(separator: "\n"))
                } else {
                    UserDefaults.standard.set(model.id ?? 0, forKey: Constants.userIdKey)
                    self?.navigationController?.pushViewController(UIStoryboard.controller(.main, type: ViewController.self, identifier: .viewController), animated: true)
                }
            case .failure(let error):
                self?.presentAlert(withTitle: "An error occurred. Please try again later", message: error.localizedDescription)
            }
        }
    }
}
