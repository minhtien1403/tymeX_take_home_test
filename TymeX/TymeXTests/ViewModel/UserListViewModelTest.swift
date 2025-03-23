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

class UserListViewModelTests: XCTestCase {
    
    var mockUsecase: MockGetListUserUsecase!
    var mockCoordinator: MockUserListCoordinator!
    var viewModel: UserListViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockUsecase = MockGetListUserUsecase()
        mockCoordinator = MockUserListCoordinator()
        viewModel = UserListViewModel(usecase: mockUsecase, navigator: mockCoordinator)
        cancellables = []
    }
    
    override func tearDown() {
        mockUsecase = nil
        mockCoordinator = nil
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testLoadUsersSuccess() {
        // Given
        let expectedUsers = [
            User(login: "john_doe", avatarURL: "https://example.com/avatar1.png", htmlURL: "https://example.com/johndoe", id: 1),
            User(login: "jane_doe", avatarURL: "https://example.com/avatar2.png", htmlURL: "https://example.com/janedoe", id: 2)
        ]
        mockUsecase.getListUserResult = Just(.success(expectedUsers))
            .eraseToAnyPublisher()
        
        let expectation = self.expectation(description: "Users fetched successfully")
        
        var result: Result<Void, NetworkRequestError>?
        
        viewModel.output.getUsersPublisher
            .sink { response in
                result = response
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.input.loadUsers()
        
        waitForExpectations(timeout: 1)
        
        // Then
        XCTAssertEqual(viewModel.output.items.count, 2)
        XCTAssertEqual(viewModel.output.items.first?.login, "john_doe")
        
        switch result {
        case .success:
            XCTAssertTrue(true)
        case .failure, .none:
            XCTFail("Expected success but got failure")
        }
    }
    
    func testLoadUsersFailure() {
        // Given
        let expectedError = NetworkRequestError.badRequest
        mockUsecase.getListUserResult = Just(.failure(expectedError))
            .eraseToAnyPublisher()
        
        let expectation = self.expectation(description: "Users fetch failed")
        
        var result: Result<Void, NetworkRequestError>?
        
        viewModel.output.getUsersPublisher
            .first()
            .sink { response in
                result = response
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When
        viewModel.input.loadUsers()
        
        waitForExpectations(timeout: 1)
        
        // Then
        switch result {
        case .failure(let error):
            XCTAssertEqual(error, expectedError)
        case .success, .none:
            XCTFail("Expected failure but got success")
        }
    }
    
    func testSinceValueUpdatesAfterFetchingUsers() {
        // Given: Initial since value is 0
        XCTAssertEqual(viewModel.since, 0)
        
        let expectedUsers = [
            User(login: "john_doe", avatarURL: "https://example.com/avatar1.png", htmlURL: "https://example.com/johndoe", id: 10),
            User(login: "jane_doe", avatarURL: "https://example.com/avatar2.png", htmlURL: "https://example.com/janedoe", id: 20)
        ]
        
        mockUsecase.getListUserResult = Just(.success(expectedUsers))
            .eraseToAnyPublisher()
        
        let expectation = self.expectation(description: "Users fetched and since updated")
        
        viewModel.output.getUsersPublisher
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When: Fetch users
        viewModel.input.loadUsers()
        
        waitForExpectations(timeout: 1)
        
        // Then: since should be updated to the last user's ID
        XCTAssertEqual(viewModel.since, 20, "since should be updated to the last user's ID")
    }
    
    func testSinceResetsToZeroWhenLastUserIDIsNil() {
        // Given: Initial since value is not 0
        viewModel.since = 100  // Set an initial value to verify reset
        
        let expectedUsers: [User] = []  // No users returned
        
        mockUsecase.getListUserResult = Just(.success(expectedUsers))
            .eraseToAnyPublisher()
        
        let expectation = self.expectation(description: "Users fetch completed with empty list")
        
        viewModel.output.getUsersPublisher
            .first()  // Ensure only the first emitted value is captured
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // When: Fetch users
        viewModel.input.loadUsers()
        
        waitForExpectations(timeout: 1)
        
        // Then: since should be reset to 0
        XCTAssertEqual(viewModel.since, 0, "since should be reset to 0 when no users are returned")
    }
    
    func testReloadResetsSinceAndFetchesUsers() {
        // Given: Set an initial `since` value
        viewModel.since = 50

        let expectedUsers = [
            User(login: "john_doe", avatarURL: "https://example.com/avatar1.png", htmlURL: "https://example.com/johndoe", id: 10)
        ]

        mockUsecase.getListUserResult = Just(.success(expectedUsers))
            .eraseToAnyPublisher()

        let expectation = self.expectation(description: "Users reload completed")

        viewModel.output.getUsersPublisher
            .first()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)

        // When: Call reload()
        viewModel.reload()

        waitForExpectations(timeout: 1)
        
        // ✅ Assert `since` **after API call completes**
        XCTAssertEqual(viewModel.since, expectedUsers.last?.id ?? 0, "since should be updated after fetching users")
    }

    func testSelectRepoTrigger() {
        // Given
        let user = User(login: "john_doe", avatarURL: "https://example.com/avatar1.png", htmlURL: "https://example.com/johndoe", id: 1)
        viewModel.users = [user]
        
        // When
        viewModel.input.selectRepoTrigger(index: 0)
        
        // Then
        XCTAssertEqual(mockCoordinator.navigatedToUserDetails, "john_doe")
    }
}
