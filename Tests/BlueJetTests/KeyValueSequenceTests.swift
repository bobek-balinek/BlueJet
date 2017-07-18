//
//  KeyValueSequenceTests.swift
//  BlueJet
//
//  Created by Przemyslaw Bobak on 17/07/2017.
//
//

import XCTest

@testable import BlueJet

class KeyValueSequenceTests: XCTestCase {

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
        let sequence = database.keyValueIterator()
        let keys: [Entry] = sequence.map { mapDataToString($0) }
        let expected: [Entry] = [
            (key: "A", value: "0"),
            (key: "B", value: "1"),
            (key: "C", value: "2"),
            (key: "D", value: "3")
        ]

        XCTAssertTrue(assertEqual(keys, expected))
    }

    func testReverseEnumeration() {
        let sequence = database.keyValueIterator(reversed: true)
        let keys: [Entry] = sequence.map { mapDataToString($0) }
        let expected: [Entry] = [
            (key: "D", value: "3"),
            (key: "C", value: "2"),
            (key: "B", value: "1"),
            (key: "A", value: "0")
        ]

        XCTAssertEqual(keys.count, 4)
        XCTAssertTrue(assertEqual(keys, expected))
    }

    // MARK: - Start Key

    func testStartKey() {
        let sequence = database.keyValueIterator(start: "B")
        let keys: [Entry] = sequence.map { mapDataToString($0) }
        let expected: [Entry] = [
            (key: "B", value: "1"),
            (key: "C", value: "2"),
            (key: "D", value: "3")
        ]

        XCTAssertEqual(keys.count, 3)
        XCTAssertTrue(assertEqual(keys, expected))
    }

    func testReverseStartKey() {
        let sequence = database.keyValueIterator(start: "B", reversed: true)
        let keys: [Entry] = sequence.map { mapDataToString($0) }
        let expected: [Entry] = [
            (key: "B", value: "1"),
            (key: "A", value: "0")
        ]

        XCTAssertEqual(keys.count, 2)
        XCTAssertTrue(assertEqual(keys, expected))
    }

    // MARK: - End Key

    func testEndKey() {
        let sequence = database.keyValueIterator(start: "A", end: "C")
        let keys: [Entry] = sequence.map { mapDataToString($0) }
        let expected: [Entry] = [
            (key: "A", value: "0"),
            (key: "B", value: "1"),
            (key: "C", value: "2")
        ]

        XCTAssertEqual(keys.count, 3)
        XCTAssertTrue(assertEqual(keys, expected))
    }

    // MARK: - Full Range

    func testRangeWithReverseOrder() {
        let sequence = database.keyValueIterator(start: "C", end: "B", reversed: true)
        let keys: [Entry] = sequence.map { mapDataToString($0) }
        let expected: [Entry] = [
            (key: "C", value: "2"),
            (key: "B", value: "1")
        ]

        XCTAssertEqual(keys.count, 2)
        XCTAssertTrue(assertEqual(keys, expected))
    }

    func testEndRangeReverseOrder() {
        let sequence = database.keyValueIterator(end: "B", reversed: true)
        let keys: [Entry] = sequence.map { mapDataToString($0) }
        let expected: [Entry] = [
            (key: "D", value: "3"),
            (key: "C", value: "2"),
            (key: "B", value: "1")
        ]

        XCTAssertEqual(keys.count, 3)
        XCTAssertTrue(assertEqual(keys, expected))
    }
}
