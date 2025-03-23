//
//  MockUserRepository.swift
//  TymeXTests
//
//  Created by Trần Tiến on 24/3/25.
//

import Foundation
import XCTest
import Combine
@testable import TymeX


class MockUserRepository: UserRepository {
    
    var getListUserResult: AnyPublisher<Result<[User], NetworkRequestError>, Never>!
    var getUserDetailsResult: AnyPublisher<Result<UserDetails, NetworkRequestError>, Never>!
    
    func getListUser(param: APIParameters.getListUser) -> AnyPublisher<Result<[User], NetworkRequestError>, Never> {
        getListUserResult
    }
    
    func getUserDetails(param: APIParameters.getUser) -> AnyPublisher<Result<UserDetails, NetworkRequestError>, Never> {
        getUserDetailsResult
    }
}
