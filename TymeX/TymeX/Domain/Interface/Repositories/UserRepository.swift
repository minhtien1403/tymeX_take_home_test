//
//  UserRepository.swift
//  TymeX
//
//  Created by Trần Tiến on 19/3/25.
//

import Combine

protocol UserRepository {
    
    func getListUser(param: APIParameters.getListUser) -> AnyPublisher<Result<[User], NetworkRequestError>, Never>
    func getUserDetails(param: APIParameters.getUser) -> AnyPublisher<Result<UserDetails, NetworkRequestError>, Never>
}
