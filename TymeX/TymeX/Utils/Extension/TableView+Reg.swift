//
//  TableView+Reg.swift
//  TymeX
//
//  Created by Trần Tiến on 21/3/25.
//

import UIKit

extension UITableView {
    
    func registerCell(_ cellType: UITableViewCell.Type) {
        self.register(UINib(nibName: "\(cellType.self)", bundle: nil), forCellReuseIdentifier: "\(cellType.self)")
    }

    func dequeueReusableCell<T: UITableViewCell>(cellType: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: "\(T.self)", for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.self)")
        }
        return cell
    }
}
