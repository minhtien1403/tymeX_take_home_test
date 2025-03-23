//
//  UserDetailsViewModel.swift
//  TymeX
//
//  Created by Trần Tiến on 21/3/25.
//

import Combine

protocol UserDetailsViewModelInputType {
    
    func loadTrigger()
}

protocol UserDetailsViewModelOutputType {
    
    var getUserDetailsPublisher: AnyPublisher<Result<UserDetails, NetworkRequestError>, Never> { get }
}

protocol UserDetailsViewModelType {
    
    var username: String { get }
    var input: UserDetailsViewModelInputType { get }
    var output: UserDetailsViewModelOutputType { get }
}

final class UserDetailsViewModel: UserDetailsViewModelType {
    
    var input: any UserDetailsViewModelInputType { self }
    var output: any UserDetailsViewModelOutputType { self }
    var username: String
    private let usecase: GetUserDetailsUsecase
    private let getUserDetailsSubject = PassthroughSubject<Result<UserDetails, NetworkRequestError>, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(username: String, usecase: GetUserDetailsUsecase) {
        self.username = username
        self.usecase = usecase
    }
    
    func getUserDetails() {
        usecase.getUserDetails(username: username)
            .sink { [weak self] result in
                self?.getUserDetailsSubject.send(result)
            }
            .store(in: &cancellables)
    }
}

extension UserDetailsViewModel: UserDetailsViewModelInputType {
    
    func loadTrigger() {
        getUserDetails()
    }
}

extension UserDetailsViewModel: UserDetailsViewModelOutputType {
    
    var getUserDetailsPublisher: AnyPublisher<Result<UserDetails, NetworkRequestError>, Never> {
        getUserDetailsSubject.eraseToAnyPublisher()
    }
}
