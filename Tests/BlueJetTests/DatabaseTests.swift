//
//  DatabaseTests.swift
//  BlueJet
//
//  Created by Przemyslaw Bobak on 14/07/2017.
//  Copyright © 2017 Spirograph Limited. All rights reserved.
//

import XCTest

@testable import BlueJet

//swiftlint:disable force_try
class DatabaseTests: XCTestCase {

    var environment: Environment!

    override func setUp() {
        super.setUp()

        do {
            environment = try Environment(path: Helpers.getPath(name))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    override func tearDown() {
        super.tearDown()

        environment.close()
        try? FileManager.default.removeItem(atPath: Helpers.getPath(name))
    }

    func testInitialiseDatabase() {
        do {
            let a = try Database(name: "bluejet", environment: environment, flags: [.create])
            XCTAssertNotNil(a)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testItFailsToCreate() {
        XCTAssertThrowsError(try Database(name: "bluejet.new", environment: environment))
    }

    func testCreateDatabase() {
        let name = "bluejet.db0"
        XCTAssertThrowsError(try Database(name: name, environment: environment))

        do {
            let db = try Database.create(name: name, environment: environment)
            XCTAssertNotNil(db)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testUnicodeDatabaseName() {
        do {
            let db = try Database.create(name: "🚀👍🏽", environment: environment)
            XCTAssertNotNil(db)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testGetValue() {
        do {
            let db = try Database.create(name: "🚀", environment: environment)
            XCTAssertNil(try db.get("💰"))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testPutValue() {
        let keyName: String = "💰"
        let val: String = "775"
        let valueData: Data? = val.data(using: .utf8)
        let db = try! Database.create(name: "🚀", environment: environment)

        do {
            /// Check if the key does not exist
            let value = try db.get(keyName)
            XCTAssertNil(value)

            /// Put the key/value pair
            try db.put(keyName, valueData)

            /// Read it again and check equality
            let newValue = try db.get(keyName)
            XCTAssertNotNil(newValue)
            XCTAssertEqual(valueData, newValue)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testEmptyPutValue() {
        let keyName: String = "Void"
        let db = try! Database.create(name: "🚀", environment: environment)

        do {
            /// Check if the key does not exist
            let value = try db.get(keyName)
            XCTAssertNil(value)

            /// Put the key with an empty value
            try db.put(keyName, nil)

            /// Read it again and check equality
            let newValue = try db.get(keyName)
            XCTAssertNil(newValue)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    func testDeleteKey() {
        let keyName: String = "Aloha"
        let val: String = "42"
        let valueData: Data? = val.data(using: .utf8)
        let db = try! Database.create(name: "🚀", environment: environment)

        do {
            /// Check if the key does not exist
            let value = try db.get(keyName)
            XCTAssertNil(value)

            /// Put the key/value pair
            try db.put(keyName, valueData)

            /// Read it again and check equality
            let newValue = try db.get(keyName)
            XCTAssertNotNil(newValue)
            XCTAssertEqual(valueData, newValue)

            // Delete the key and check
            try db.delete(keyName)
            XCTAssertNil(try db.get(keyName))
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    static var allTests: [(String, (DatabaseTests) -> () throws -> Void)] {
        return [
            ("testInitialiseDatabase", testInitialiseDatabase),
            ("testItFailsToCreate", testItFailsToCreate),
            ("testCreateDatabase", testCreateDatabase),
            ("testUnicodeDatabaseName", testUnicodeDatabaseName),
            ("testGetValue", testGetValue),
            ("testPutValue", testPutValue),
            ("testEmptyPutValue", testEmptyPutValue),
            ("testDeleteKey", testDeleteKey)
        ]
    }
}
