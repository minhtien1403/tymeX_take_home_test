//
//  UserDetailsView.swift
//  TymeX
//
//  Created by Trần Tiến on 21/3/25.
//

import UIKit
import Combine

class UserDetailsView: UIViewController {
    
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var numberOfFollowerLabel: UILabel!
    @IBOutlet private weak var numberOfFollowingLabel: UILabel!
    @IBOutlet private weak var blogLinkLabel: UILabel!
    @IBOutlet weak var followingImageView: UIImageView!
    @IBOutlet weak var followerImageView: UIImageView!
    private let viewModel: UserDetailsViewModelType
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: UserDetailsViewModelType) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        viewModel.input.loadTrigger()
    }
    

    
    private func setupUI() {
        title = viewModel.username
        containerView.isHidden = true
        indicatorView.startAnimating()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
        avatarImageView.clipsToBounds = true
        followerImageView.layer.cornerRadius = followerImageView.frame.size.width / 2
        followerImageView.clipsToBounds = true
        followingImageView.layer.cornerRadius = followingImageView.frame.size.width / 2
        followingImageView.clipsToBounds =  true
    }
    
    private func bind() {
        let output = viewModel.output
        output.getUserDetailsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.indicatorView.isHidden = true
                switch result {
                case .success(let userDetails):
                    self?.onGetUserDetailsSuccess(userDetails: userDetails)
                case .failure(let error):
                    print("[Error] \(String(describing: error.errorDescription))")
                }
            }
            .store(in: &cancellables)
    }

    private func onGetUserDetailsSuccess(userDetails: UserDetails) {
        containerView.isHidden = false
        avatarImageView.kf.setImage(with: URL(string: userDetails.avatarURL))
        nameLabel.text = userDetails.login
        locationLabel.text = userDetails.location ?? "n/a"
        numberOfFollowerLabel.text = "\(userDetails.followers)"
        numberOfFollowingLabel.text = "\(userDetails.following)"
        blogLinkLabel.text = userDetails.blog
    }
}
