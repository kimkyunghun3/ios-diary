//
//  AlertAction.swift
//  Diary
//
//  Created by Eddy, safari on 2022/06/21.
//

import UIKit

struct AlertAction {
    let title: String
    let style: UIAlertAction.Style
    let completion: (() -> Void)?
}
