//
//  Helpers.swift
//  BlueJet
//
//  Created by Przemyslaw Bobak on 14/07/2017.
//  Copyright © 2017 Spirograph Limited. All rights reserved.
//

import Foundation
import XCTest

typealias Entry = (key: String, value: String?)

func escapeName(_ text: String?) -> String? {
    return text?
        .replacingOccurrences(of: "[", with: "")
        .replacingOccurrences(of: "]", with: "")
        .replacingOccurrences(of: "-", with: "")
        .replacingOccurrences(of: " ", with: "")
}

func mapDataToString(_ pair: (key: Data, value: Data?)) -> Entry {
    return (
        key: String(data: pair.key, encoding: .utf8)!,
        value: pair.value != nil ? String(data: pair.value!, encoding: .utf8) : nil
    )
}

struct Helpers {

    static func getDBName(_ instance: XCTestCase, _ name: String?) -> String {
        return escapeName(name) ?? String(describing: instance)
    }

    static func getPath(_ name: String? = nil) -> String {
        let safeFileName = escapeName(name)
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
        let envURL = tempURL.appendingPathComponent(safeFileName ?? "BlueJetTests")

        do {
            try FileManager.default.createDirectory(at: envURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            XCTFail("Could not create DB dir: \(error)")
        }

        return envURL.path
    }
}

func == (lhs: Entry, rhs: Entry) -> Bool {
    return lhs.key == rhs.key && lhs.value == rhs.value
}

func assertEqual(_ entry: [Entry], _ anotherEntry: [Entry]) -> Bool {
    guard entry.count == anotherEntry.count else {
        return false
    }

    var valid: Bool = true

    entry.enumerated().forEach { (offset: Int, _: Entry) in
        if valid {
            valid = entry[offset] == anotherEntry[offset]
        }
    }

    return valid
}
