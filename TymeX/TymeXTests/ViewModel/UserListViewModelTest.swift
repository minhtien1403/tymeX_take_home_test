//
//  UserListViewModelTest.swift
//  TymeXTests
//
//  Created by Trần Tiến on 24/3/25.
//

import Foundation
import Combine
import XCTest
@testable import TymeX

import XCTest
import Combine

class UserListViewModelTests: XCTestCase {
    
    private var viewModel: UserListViewModel!
    private var mockUsecase: MockGetListUserUsecase!
    private var mockCoordinator: MockUserListCoordinator!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockUsecase = MockGetListUserUsecase()
        mockCoordinator = MockUserListCoordinator()
        viewModel = UserListViewModel(usecase: mockUsecase, navigator: mockCoordinator)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockUsecase = nil
        mockCoordinator = nil
        cancellables = nil
        super.tearDown()
    }
    
    // Test: `reload()` should reset `since = 0` and call usecase
    func testReloadCallsUsecaseWithSinceZero() {
        viewModel.since = 50  // Simulate a previous fetch
        let expectation = self.expectation(description: "Usecase called with since = 0")

        mockUsecase.getListUserClosure = { perPage, since in
            XCTAssertEqual(since, 0, "Expected since to be 0 when reload() is called")
            expectation.fulfill()
            return Just(.success([])).eraseToAnyPublisher()
        }

        viewModel.reload()
        waitForExpectations(timeout: 1)
    }

    // Test: Fetch users successfully updates the users list
    func testGetUsersSuccess() {
        let expectedUsers = [
            User(login: "john_doe", avatarURL: "https://example.com/avatar1.png", htmlURL: "https://example.com/johndoe", id: 10)
        ]
        
        let expectation = self.expectation(description: "Users fetch successful")

        mockUsecase.getListUserClosure = { perPage, since in
            XCTAssertEqual(perPage, 20, "Expected perPage to be 20")
            return Just(.success(expectedUsers)).eraseToAnyPublisher()
        }

        viewModel.output.getUsersPublisher
            .first()
            .sink { result in
                switch result {
                case .success:
                    XCTAssertEqual(self.viewModel.items.count, expectedUsers.count, "Users count should match expected users count")
                    XCTAssertEqual(self.viewModel.since, expectedUsers.last?.id ?? 0, "since should be updated to last user ID")
                case .failure:
                    XCTFail("Expected success but got failure")
                }
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.input.loadUsers()
        waitForExpectations(timeout: 1)
    }
    
    // Test: Failure case should publish an error
    func testLoadUsersFailure() {
        let expectedError = NetworkRequestError.badRequest
        let expectation = self.expectation(description: "Users fetch failed")

        mockUsecase.getListUserClosure = { _, _ in
            return Just(.failure(expectedError)).eraseToAnyPublisher()
        }

        viewModel.output.getUsersPublisher
            .first()
            .sink { result in
                switch result {
                case .failure(let error):
                    XCTAssertEqual(error, expectedError, "Expected the same error")
                case .success:
                    XCTFail("Expected failure but got success")
                }
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.input.loadUsers()
        waitForExpectations(timeout: 1)
    }
    
    // Test: `since` updates to 0 when last ID is nil
    func testSinceBecomesZeroWhenLastIDIsNil() {
        let expectation = self.expectation(description: "Since becomes 0 when last user ID is nil")

        mockUsecase.getListUserClosure = { _, _ in
            return Just(.success([])).eraseToAnyPublisher()
        }

        viewModel.output.getUsersPublisher
            .first()
            .sink { _ in
                XCTAssertEqual(self.viewModel.since, 0, "Since should be 0 when no users are returned")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.input.loadUsers()
        waitForExpectations(timeout: 1)
    }
    
    // Test: userNameToNavigate should be username selected
    func testSelectRepoTriggerCallsCoordinatorWithCorrectUsername() {
        // Given
        let expectedUser = User(
            login: "john_doe",
            avatarURL: "https://example.com/avatar1.png",
            htmlURL: "https://example.com/johndoe",
            id: 10
        )

        viewModel.users = [expectedUser] // Simulate a loaded user list

        // When
        viewModel.input.selectRepoTrigger(index: 0)

        // Then
        XCTAssertEqual(mockCoordinator.userNameToNavigate, expectedUser.login, "Coordinator should be called with the correct username")
    }
}
