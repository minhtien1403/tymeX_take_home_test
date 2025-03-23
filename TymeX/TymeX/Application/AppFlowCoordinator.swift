//
//  AppFlowCoordinator.swift
//  TymeX
//
//  Created by Trần Tiến on 23/3/25.
//

import UIKit

final class AppFlowCoordinator {
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        let backImage = UIImage(systemName: "chevron.left")
        navigationController.navigationBar.backIndicatorImage = backImage
        navigationController.navigationBar.backIndicatorTransitionMaskImage = backImage
        navigationController.navigationBar.tintColor = .black
        navigationController.navigationItem.backBarButtonItem?.title = ""
    }
    
    func start() {
        let repository = UserRepositoryImpl()
        let usecase = GetListUserUsecaseImpl(userRepository: repository)
        let navigator = UserListCoordinatorImpl(navigationController: navigationController)
        let viewModel = UserListViewModel(usecase: usecase, navigator: navigator)
        let view = UserListView(viewModel: viewModel)
        navigationController.pushViewController(view, animated: true)
    }
}
