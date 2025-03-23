//
//  GetUserDetailsUsecase.swift
//  TymeX
//
//  Created by Trần Tiến on 19/3/25.
//

import Combine

protocol GetUserDetailsUsecase {
    
    func getUserDetails(username: String) -> AnyPublisher<Result<UserDetails, NetworkRequestError>, Never>
}

class GetUserDetailsUsecaseImpl: GetUserDetailsUsecase {
    
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func getUserDetails(username: String) -> AnyPublisher<Result<UserDetails, NetworkRequestError>, Never> {
        userRepository.getUserDetails(param: .init(username: username))
    }
}
