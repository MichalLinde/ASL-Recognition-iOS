//
//  AlertManager.swift
//  ASL Recognition
//
//  Created by Michał on 16/12/2022.
//

import Foundation
import UIKit

class AlertManager {
    static func showActionSheetMessage(title: String? = nil, message: String? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        return alert
    }
}
