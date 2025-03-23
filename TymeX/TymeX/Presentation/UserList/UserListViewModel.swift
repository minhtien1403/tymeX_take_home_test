//
//  UserListViewModel.swift
//  TymeX
//
//  Created by Trần Tiến on 20/3/25.
//

import Combine

protocol UserListViewModelInputType {
    
    func reload()
    func loadUsers()
    func selectRepoTrigger(index: Int)
}

protocol UserListViewModelOutputType {
    
    var items: [User] { get }
    var getUsersPublisher: AnyPublisher<Result<Void, NetworkRequestError>, Never> { get }
}

protocol UserListViewModelType {
    
    var input: UserListViewModelInputType { get }
    var output: UserListViewModelOutputType { get }
}

final class UserListViewModel: UserListViewModelType {
    
    var input: UserListViewModelInputType { self }
    var output: UserListViewModelOutputType { self }
    
    private let usecase: GetListUserUsecase
    private let coordinator: UserListCoordinator
    private var cancellables = Set<AnyCancellable>()
    private let getUsersSubject = PassthroughSubject<Result<Void, NetworkRequestError>, Never>()
    let perPage = 20
    var since = 0
    var users: [User] = []
    
    init(usecase: GetListUserUsecase, navigator: UserListCoordinator) {
        self.usecase = usecase
        self.coordinator = navigator
    }
    
    func getUsers() {
        usecase.getListUser(perPage: perPage, since: since)
            .sink { [weak self] result in
                switch result {
                case .success(let users):
                    self?.appendUser(users: users)
                case .failure(let error):
                    self?.getUsersSubject.send(.failure(error))
                }
                self?.getUsersSubject.send(.success(()))
            }
            .store(in: &cancellables)
    }
    
    func appendUser(users: [User]) {
        self.users += users
        since = users.last?.id ?? 0
    }
}

extension UserListViewModel: UserListViewModelInputType {
    
    func reload() {
        since = 0
        getUsers()
    }
    
    func loadUsers() {
        getUsers()
    }
    
    func selectRepoTrigger(index: Int) {
        let username = users[index].login
        coordinator.goToUserDetails(username: username)
    }
}

extension UserListViewModel: UserListViewModelOutputType {
    
    var getUsersPublisher: AnyPublisher<Result<Void, NetworkRequestError>, Never> {
        getUsersSubject.eraseToAnyPublisher()
    }
    
    var items: [User] {
        users
    }
}
