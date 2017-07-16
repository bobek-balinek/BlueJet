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

    override func setUp() {
        super.setUp()

        environment = try! Environment(path: Helpers.getPath())
        database = try! Database.create(name: "Keys", environment: environment)
        try! database.put("A", "0".data())
        try! database.put("B", "1".data())
        try! database.put("C", "2".data())
        try! database.put("D", "3".data())
    }

    override func tearDown() {
        super.tearDown()

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

    func testStartKey() {
        let sequence = database.keyIterator(start: "B")
        let keys: [String] = sequence.map { String(data: $0, encoding: .utf8)! }

        XCTAssertEqual(keys.count, 3)
        XCTAssertEqual(keys, ["B", "C", "D"])
    }

    func testEndKey() {
        let sequence = database.keyIterator(start: "A", end: "C")
        let keys: [String] = sequence.map { String(data: $0, encoding: .utf8)! }

        XCTAssertEqual(keys.count, 3)
        XCTAssertEqual(keys, ["A", "B", "C"])
    }
}
