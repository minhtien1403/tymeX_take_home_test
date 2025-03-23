//
//  UserListNavigator.swift
//  TymeX
//
//  Created by Trần Tiến on 23/3/25.
//

import UIKit

protocol UserListCoordinator {
         
    func goToUserDetails(username: String)
}

class UserListCoordinatorImpl: UserListCoordinator {
    
    private var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func goToUserDetails(username: String) {
        let repository = UserRepositoryImpl()
        let usecase = GetUserDetailsUsecaseImpl(userRepository: repository)
        let viewModel = UserDetailsViewModel(username: username, usecase: usecase)
        let view = UserDetailsView(viewModel: viewModel)
        navigationController.pushViewController(view, animated: true)
    }
}

