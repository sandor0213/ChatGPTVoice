//
//  RegistrationViewController.swift
//  ChildQuestionApp
//
//  Created by alex on 07.02.2023.
//

import UIKit

final class RegistrationViewController: AuthorizationViewController {
    
    @IBAction func signUpAction(_ sender: Any) {
        guard isValidInputs() else { return }
        
        signUp()
    }
    
    @IBAction func redirectToSignIp(_ sender: Any) {
        navigationController?.pushViewController(UIStoryboard.controller(.main, type: LoginViewController.self, identifier: .loginViewController), animated: true)
    }
}

private extension RegistrationViewController {
    func signUp() {
        NetworkManager.Authorization.signUp(model: AuthRequestModel(user: AuthModel(email: emailTextField.text, password: passwordTextField.text))) { [weak self] result in
            switch result {
            case .success(let model):
                if model.id == nil || !(model.errors?.email?.isEmpty ?? true) {
                    self?.presentAlert(withTitle: model.errors?.email?.joined(separator: "\n"))
                } else {
                    self?.navigationController?.pushViewController(UIStoryboard.controller(.main, type: LoginViewController.self, identifier: .loginViewController), animated: true)
                }
            case .failure:
                self?.presentUnknownAlert()
            }
        }
    }
}
