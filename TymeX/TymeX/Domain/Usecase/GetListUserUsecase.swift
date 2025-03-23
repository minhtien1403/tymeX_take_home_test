//
//  GetListUserUsecase.swift
//  TymeX
//
//  Created by Trần Tiến on 19/3/25.
//

import Combine

protocol GetListUserUsecase {
    
    func getListUser(perPage: Int, since: Int) -> AnyPublisher<Result<[User], NetworkRequestError>, Never>
}

class GetListUserUsecaseImpl: GetListUserUsecase {
    
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func getListUser(perPage: Int, since: Int) -> AnyPublisher<Result<[User], NetworkRequestError>, Never> {
        userRepository.getListUser(param: .init(perPage: perPage, since: since))
    }
}
