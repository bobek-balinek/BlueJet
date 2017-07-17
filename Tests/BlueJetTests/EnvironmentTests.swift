//
//  EnvironmentTests.swift
//  BlueJet
//
//  Created by Przemyslaw Bobak on 13/07/2017.
//  Copyright © 2017 Spirograph Limited. All rights reserved.
//

import XCTest

@testable import BlueJet

class EnvironmentTests: XCTestCase {

    override func tearDown() {
        super.tearDown()

        try? FileManager.default.removeItem(atPath: Helpers.getPath())
    }

    func testCreateEnvironment() {
        do {
            let a = try Environment(path: Helpers.getPath())
            XCTAssertNotNil(a)
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
    }

    func testFailedCreateEnvironment() {
        let invalidConfiguration: Environment.Configuration = Environment.Configuration(
            flags: [],
            maximumDBs: 0,
            maxReaders: 0,
            mapSize: 0
        )
        XCTAssertThrowsError(try Environment(path: ""))
        XCTAssertThrowsError(try Environment(path: "", configuration: invalidConfiguration))
    }

    static var allTests: [(String, (EnvironmentTests) -> () throws -> Void)] {
        return [
            ("testCreateEnvironment", testCreateEnvironment),
            ("testFailedCreateEnvironment", testFailedCreateEnvironment)
        ]
    }
}
