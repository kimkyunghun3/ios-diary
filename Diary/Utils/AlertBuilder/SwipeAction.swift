//
//  SwipeAction.swift
//  Diary
//
//  Created by Eddy, safari on 2022/06/21.
//

import UIKit

struct SwipeAction {
    let title: String?
    let style: UIContextualAction.Style
    let image: UIImage?
    let backgroundColor: UIColor?
    let action: (() -> Void)?
}
