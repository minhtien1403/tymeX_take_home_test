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
    var getListUserResult: AnyPublisher<Result<[User], NetworkRequestError>, Never>!
    
    func getListUser(perPage: Int, since: Int) -> AnyPublisher<Result<[User], NetworkRequestError>, Never> {
        return getListUserResult
    }
}

class MockUserListCoordinator: UserListCoordinator {
    var navigatedToUserDetails: String?
    
    func goToUserDetails(username: String) {
        navigatedToUserDetails = username
    }
}
