//
//  UserInfoTableViewCell.swift
//  TymeX
//
//  Created by Trần Tiến on 20/3/25.
//

import UIKit
import Kingfisher

class UserInfoTableViewCell: UITableViewCell {

    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var openUrlButton: UIButton!
    private var attrs = [
        NSAttributedString.Key.font : UIFont.systemFont(ofSize: 19.0),
        NSAttributedString.Key.foregroundColor : UIColor.link,
        NSAttributedString.Key.underlineStyle : 1
    ] as [NSAttributedString.Key : Any]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setupCell() {
        containerView.applyShadow()
        containerView.layer.cornerRadius = 10
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
        avatarImageView.clipsToBounds = true
    }
    
    func configCellData(username: String, url: String, avatarURL: String) {
        usernameLabel.text = username
        let buttonTitleStr = NSMutableAttributedString(string: url, attributes: attrs)
        let attributedString = NSMutableAttributedString(attributedString: buttonTitleStr)
        openUrlButton.setAttributedTitle(attributedString, for: .normal)
        avatarImageView.kf.setImage(with: URL(string: avatarURL))
    }
    
    @IBAction func openURLButtonDidTap(_ sender: UIButton) {
        print("tapped")
    }
}
