//
//  UIStoryboard+Extension.swift
//  ChildQuestionApp
//
//  Created by alex on 07.02.2023.
//

import UIKit

extension UIStoryboard {
    enum Item: String {
        case main = "Main"
    }
    
    enum ControllerIdentifier: String {
        // Main
        case loginViewController = "LoginViewController"
        case registrationViewController = "RegistrationViewController"
        case viewController = "ViewController"
    }
}

extension UIStoryboard {
    static func controller<T: UIViewController>(_ storyboard: Item, type: T.Type? = nil, identifier: ControllerIdentifier? = nil) -> T {
        let initialViewController = UIStoryboard(name: storyboard.rawValue, bundle: Bundle.main).instantiateViewController(withIdentifier: identifier == nil ? String(describing: type.self) : identifier!.rawValue) as! T
        return initialViewController
    }
}
