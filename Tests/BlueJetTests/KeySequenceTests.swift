//
//  KeySequenceTests.swift
//  BlueJet
//
//  Created by Przemyslaw Bobak on 15/07/2017.
//
//

import XCTest

@testable import BlueJet

//swiftlint:disable force_try
class KeySequenceTests: XCTestCase {

    var environment: Environment!
    var database: Database!
    var dbName: String!

    override func setUp() {
        super.setUp()

        dbName = Helpers.getDBName(self, name)

        do {
            environment = try Environment(path: Helpers.getPath())
            database = try Database.create(name: dbName, environment: environment)
            try database.put("A", "0".data())
            try database.put("B", "1".data())
            try database.put("C", "2".data())
            try database.put("D", "3".data())
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    override func tearDown() {
        super.tearDown()

        database.close()
        environment.close()
        try? FileManager.default.removeItem(atPath: Helpers.getPath())
    }

    func testEnumeration() {
        let sequence = database.keyIterator()
        let keys: [String] = sequence.map { String(data: $0, encoding: .utf8)! }

        XCTAssertEqual(keys.count, 4)
        XCTAssertEqual(keys, ["A", "B", "C", "D"])
    }

    func testReverseEnumeration() {
        let sequence = database.keyIterator(reversed: true)
        let keys: [String] = sequence.map { String(data: $0, encoding: .utf8)! }

        XCTAssertEqual(keys.count, 4)
        XCTAssertEqual(keys, ["D", "C", "B", "A"])
    }

    // MARK: - Start Key

    func testStartKey() {
        let sequence = database.keyIterator(start: "B")
        let keys: [String] = sequence.map { String(data: $0, encoding: .utf8)! }

        XCTAssertEqual(keys.count, 3)
        XCTAssertEqual(keys, ["B", "C", "D"])
    }

    func testReverseStartKey() {
        let sequence = database.keyIterator(start: "B", reversed: true)
        let keys: [String] = sequence.map { String(data: $0, encoding: .utf8)! }

        XCTAssertEqual(keys.count, 2)
        XCTAssertEqual(keys, ["B", "A"])
    }

    // MARK: - End Key

    func testEndKey() {
        let sequence = database.keyIterator(start: "A", end: "C")
        let keys: [String] = sequence.map { String(data: $0, encoding: .utf8)! }

        XCTAssertEqual(keys.count, 3)
        XCTAssertEqual(keys, ["A", "B", "C"])
    }

    // MARK: - Full Range

    func testRangeWithReverseOrder() {
        let sequence = database.keyIterator(start: "C", end: "B", reversed: true)
        let keys: [String] = sequence.map { String(data: $0, encoding: .utf8)! }

        XCTAssertEqual(keys.count, 2)
        XCTAssertEqual(keys, ["C", "B"])
    }

    func testEndRangeReverseOrder() {
        let sequence = database.keyIterator(end: "B", reversed: true)
        let keys: [String] = sequence.map { String(data: $0, encoding: .utf8)! }

        XCTAssertEqual(keys.count, 3)
        XCTAssertEqual(keys, ["D", "C", "B"])
    }
}
