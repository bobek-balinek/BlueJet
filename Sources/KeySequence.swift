//
//  KeySequence.swift
//  BlueJet
//
//  Created by Przemyslaw Bobak on 15/07/2017.
//
//

import Foundation
#if SWIFT_PACKAGE
import CLMDB
#endif

/// Key Sequence type
public struct KeySequence: Sequence {

    /// Defines the type of the iterator
    public typealias Iterator = KeyIterator

    /// Query to run the iterator with
    private let query: Query

    /// Initialise a key-only sequence
    ///
    /// - Parameter query: Query to run the iterator with
    init(query: Query) {
        self.query = query
    }

    /// Returns an iterator over the elements of this sequence.
    ///
    /// - Returns: Iterator instance
    public func makeIterator() -> Iterator {
        do {
            let transaction = try Transaction(environment: query.database.environment)
            let cursor = Cursor(transaction: transaction, query: self.query)

            return KeyIterator(cursor: cursor, operation: cursor.operation, nextOperation: cursor.nextOperation)
        } catch {
            // Return an empty iterator
            return KeyIterator()
        }
    }
}
