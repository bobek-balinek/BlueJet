//
//  Helpers.swift
//  BlueJet
//
//  Created by Przemyslaw Bobak on 14/07/2017.
//  Copyright © 2017 Spirograph Limited. All rights reserved.
//

import Foundation
import XCTest

struct Helpers {
    static func getPath(_ name: String? = nil) -> String {
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
        let envURL = tempURL.appendingPathComponent(name ?? "BlueJetTests")

        do {
            try FileManager.default.createDirectory(at: envURL, withIntermediateDirectories: true, attributes: nil)
        } catch {
            XCTFail("Could not create DB dir: \(error)")
        }

        return envURL.path
    }
}
