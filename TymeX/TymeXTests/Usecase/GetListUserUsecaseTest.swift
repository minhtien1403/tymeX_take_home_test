//
//  GetListUserUsecaseTest.swift
//  TymeXTests
//
//  Created by Trần Tiến on 24/3/25.
//

import Foundation
import XCTest
import Combine
@testable import TymeX

class GetListUserUsecaseTests: XCTestCase {
    
    var mockUserRepository: MockUserRepository!
    var usecase: GetListUserUsecaseImpl!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockUserRepository = MockUserRepository()
        usecase = GetListUserUsecaseImpl(userRepository: mockUserRepository)
        cancellables = []
    }
    
    override func tearDown() {
        mockUserRepository = nil
        usecase = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testGetListUserSuccess() {
        // Given
        let expectedUsers = [
            User(login: "john_doe", avatarURL: "https://example.com/avatar1.png", htmlURL: "https://example.com/johndoe", id: 1),
            User(login: "jane_doe", avatarURL: "https://example.com/avatar2.png", htmlURL: "https://example.com/janedoe", id: 2)
        ]
        mockUserRepository.getListUserResult = Just(.success(expectedUsers))
            .eraseToAnyPublisher()
        
        let perPage = 10
        let since = 0
        
        // When
        var result: Result<[User], NetworkRequestError>?
        let expectation = self.expectation(description: "Fetch list of users")
        
        usecase.getListUser(perPage: perPage, since: since)
            .sink(receiveValue: { response in
                result = response
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1)
        
        // Then
        XCTAssertNotNil(result)
        switch result {
        case .success(let users):
            XCTAssertEqual(users.count, 2)
            XCTAssertEqual(users.first?.login, "john_doe")
            XCTAssertEqual(users.first?.avatarURL, "https://example.com/avatar1.png")
            XCTAssertEqual(users.first?.htmlURL, "https://example.com/johndoe")
        case .failure:
            XCTFail("Expected success but got failure")
        case .none:
            XCTFail("No result received")
        }
    }
    
    func testGetListUserFailure() {
        // Given
        let expectedError = NetworkRequestError.badRequest
        mockUserRepository.getListUserResult = Just(.failure(expectedError))
            .eraseToAnyPublisher()
        
        let perPage = 10
        let since = 0
        
        // When
        var result: Result<[User], NetworkRequestError>?
        let expectation = self.expectation(description: "Fetch list of users failure")
        
        usecase.getListUser(perPage: perPage, since: since)
            .sink(receiveValue: { response in
                result = response
                expectation.fulfill()
            })
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 1)
        
        // Then
        XCTAssertNotNil(result)
        switch result {
        case .failure(let error):
            XCTAssertEqual(error, expectedError)
        case .success:
            XCTFail("Expected failure but got success")
        case .none:
            XCTFail("No result received")
        }
    }
}
