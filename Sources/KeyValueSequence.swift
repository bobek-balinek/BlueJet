//
//  KeyValueSequence.swift
//  BlueJet
//
//  Created by Przemyslaw Bobak on 17/07/2017.
//
//

import Foundation

/// Key Sequence type
public struct KeyValueSequence: Sequence {

    /// Defines the type of the iterator
    public typealias Iterator = KeyValueIterator

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
            let cursor = transaction.cursor(for: query)

            return Iterator(cursor: cursor, operation: cursor.operation, nextOperation: cursor.nextOperation)
        } catch {
            // Return an empty iterator
            return Iterator()
        }
    }
}
