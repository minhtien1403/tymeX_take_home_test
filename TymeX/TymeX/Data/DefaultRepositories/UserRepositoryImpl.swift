//
//  DefaultUserRepository.swift
//  TymeX
//
//  Created by Trần Tiến on 19/3/25.
//

import Combine

class UserRepositoryImpl: UserRepository {
    
    func getListUser(param: APIParameters.getListUser) -> AnyPublisher<Result<[User], NetworkRequestError>, Never> {
        NetworkServices.shared.request(request: APIEndPoint.getUsers(queryParams: param))
    }
    
    func getUserDetails(param: APIParameters.getUser) -> AnyPublisher<Result<UserDetails, NetworkRequestError>, Never> {
        NetworkServices.shared.request(request: APIEndPoint.getUser(param: param))
    }
}
