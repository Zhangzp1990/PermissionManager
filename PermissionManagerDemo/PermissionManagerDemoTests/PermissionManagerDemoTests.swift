//
//  PermissionManagerDemoTests.swift
//  PermissionManagerDemoTests
//
//  Created by zhangzp on 2023/7/3.
//

import XCTest
@testable import PermissionManagerDemo

final class PermissionManagerDemoTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testCamera() {
        Task {
            let status = await Permissions.requestAccess(.camera)
            let isAuthorized = await Permissions.isAuthorized(.camera)
            XCTAssertEqual(status, isAuthorized)
        }
    }
    
    func testPhotoLibrary() {
        Task {
            let status = await Permissions.requestAccess(.photoLibrary)
            let isAuthorized = await Permissions.isAuthorized(.photoLibrary)
            XCTAssertEqual(status, isAuthorized)
        }
    }
}
