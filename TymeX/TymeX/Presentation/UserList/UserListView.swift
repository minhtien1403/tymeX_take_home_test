//
//  UserListView.swift
//  TymeX
//
//  Created by Trần Tiến on 20/3/25.
//

import UIKit
import Combine

class UserListView: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    private let viewModel: UserListViewModelType
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: UserListViewModelType) {
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
        viewModel.input.loadUsers()
    }
    
    private func setupUI() {
        title = "Github Users"
        tableView.registerCell(UserInfoTableViewCell.self)
        tableView.registerCell(LoadmoreCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        loadingIndicator.isHidden = false
        navigationItem.backButtonTitle = ""
        loadingIndicator.startAnimating()
    }
    
    private func bind() {
        let output = viewModel.output
        output.getUsersPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.loadingIndicator.stopAnimating()
                switch result {
                case .success:
                    self?.loadingIndicator.isHidden = true
                    self?.tableView.isHidden = false
                    self?.tableView.reloadData()
                case .failure(let error):
                    self?.showAlert(message: error.errorDescription ?? "n/a", buttonTitle: "Refresh", action: {
                        self?.loadingIndicator.isHidden = false
                        self?.loadingIndicator.startAnimating()
                        self?.viewModel.input.reload()
                    })
                }
            }
            .store(in: &cancellables)
    }
}

extension UserListView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.output.items.count != 0 {
            return viewModel.output.items.count + 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = viewModel.output.items
        if indexPath.row < data.count {
            let cell = tableView.dequeueReusableCell(cellType: UserInfoTableViewCell.self, for: indexPath)
            cell.configCellData(
                username: data[indexPath.row].login,
                url: data[indexPath.row].htmlURL,
                avatarURL: data[indexPath.row].avatarURL
            )
            return cell
        } else {
            return tableView.dequeueReusableCell(cellType: LoadmoreCell.self, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.output.items.count - 1 {
            viewModel.input.loadUsers()
        }
    }
}

extension UserListView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel.input.selectRepoTrigger(index: indexPath.row)
    }
}
