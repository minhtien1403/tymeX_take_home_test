//
//  LoadmoreCell.swift
//  TymeX
//
//  Created by Trần Tiến on 21/3/25.
//

import UIKit

class LoadmoreCell: UITableViewCell {

    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        indicator.startAnimating()
        selectionStyle = .none
    }
}
