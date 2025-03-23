//
//  MockGetListUserUsecase.swift
//  TymeXTests
//
//  Created by Trần Tiến on 24/3/25.
//

import Foundation
import Combine
@testable import TymeX

class MockGetListUserUsecase: GetListUserUsecase {
    
    var getListUserClosure: ((Int, Int) -> AnyPublisher<Result<[User], NetworkRequestError>, Never>)?
    
    func getListUser(perPage: Int, since: Int) -> AnyPublisher<Result<[User], NetworkRequestError>, Never> {
        return getListUserClosure?(perPage, since) ?? Just(.success([])).eraseToAnyPublisher()
    }
}


class MockUserListCoordinator: UserListCoordinator {
    
    var userNameToNavigate: String?
    
    func goToUserDetails(username: String) {
        userNameToNavigate = username
    }
}
