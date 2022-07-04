//
//  AlertBuilder.swift
//  Diary
//
//  Created by Eddy, safari on 2022/06/21.
//

import UIKit

final class AlertBuilder {
    private weak var viewController: UIViewController?
    private var alertActions: [AlertAction] = []
    
    init(target: UIViewController) {
        self.viewController = target
    }
    
    func addAction(_ title: String, style: UIAlertAction.Style, action: (() -> Void)? = nil) -> Self {
        let alertAction = AlertAction(title: title, style: style, completion: action)
        alertActions.append(alertAction)
        
        return self
    }
    
    func show(_ title: String? = nil, message: String? = nil, style: UIAlertController.Style) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        alertActions.forEach { action in
            let alertAction = UIAlertAction(title: action.title, style: action.style) { _ in
                action.completion?()
            }
            alertController.addAction(alertAction)
        }
        viewController?.present(alertController, animated: true)
    }
}
