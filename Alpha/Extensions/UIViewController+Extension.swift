//
//  UIViewController+Extension.swift
//  ChildQuestionApp
//
//  Created by alex on 07.02.2023.
//

import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func presentAlert(withTitle title: String? = nil, message : String? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OkAction = UIAlertAction(title: "OK", style: .default) { action in }
        alertController.addAction(OkAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentUnknownAlert(withTitle title: String = "An error occurred. please try again later") {
     presentAlert(withTitle: title)
    }
}
