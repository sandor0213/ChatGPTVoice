//
//  MainNavigationController.swift
//  ChildQuestionApp
//
//  Created by alex on 09.02.2023.
//

import UIKit

final class MainNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setRootController()
    }
}

extension MainNavigationController {
    func setRootController() {
        // shorthand - not readable
//        setViewControllers([(UserDefaults.standard.string(forKey: Constants.authorizationTokenKey)?.isEmpty ?? true) ? UIStoryboard.controller(.main, identifier: .loginViewController) : UIStoryboard.controller(.main, identifier: .viewController)], animated: false)
        
        if let access = UserDefaults.standard.string(forKey: Constants.authorizationTokenKey), !access.isEmpty {
            let rootController = UIStoryboard.controller(.main, identifier: .viewController)
            setViewControllers([rootController], animated: false)
        } else {
            let rootController = UIStoryboard.controller(.main, identifier: .loginViewController)
            setViewControllers([rootController], animated: false)
        }
    }
}
