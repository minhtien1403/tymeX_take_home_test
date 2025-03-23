//
//  UIViewController+Alert.swift
//  TymeX
//
//  Created by Trần Tiến on 24/3/25.
//

import UIKit

extension UIViewController {
    
    func showAlert(message: String, buttonTitle: String = "OK", action: @escaping () -> Void = {} ) {
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: buttonTitle, style: .default) { _ in
            action()
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
