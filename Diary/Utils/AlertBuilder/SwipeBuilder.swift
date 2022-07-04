//
//  SwipeBuilder.swift
//  Diary
//
//  Created by Eddy, safari on 2022/06/21.
//

import UIKit

final class SwipeBuilder {
    private var swipeActions: [SwipeAction] = []
    
    func addAction(
        title: String,
        style: UIContextualAction.Style,
        image: UIImage? = nil,
        backgroundColor: UIColor? = nil,
        action: (() -> Void)?) -> Self {
            let swipeAction = SwipeAction(
                title: title,
                style: style,
                image: image,
                backgroundColor: backgroundColor,
                action: action)
            swipeActions.append(swipeAction)
            
            return self
        }
    
    func show() -> UISwipeActionsConfiguration {
        let swipeButtons = swipeActions.map { swipeAction -> UIContextualAction in
            let contextualAction = UIContextualAction(
                style: swipeAction.style,
                title: swipeAction.title) { _, _, completion in
                swipeAction.action?()
                completion(true)
            }
            contextualAction.image = swipeAction.image
            contextualAction.backgroundColor = swipeAction.backgroundColor
            
            return contextualAction
        }
        return UISwipeActionsConfiguration(actions: swipeButtons)
    }
}
