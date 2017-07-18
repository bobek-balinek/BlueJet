//
//  KeyValueIterator.swift
//  BlueJet
//
//  Created by Przemyslaw Bobak on 17/07/2017.
//
//

import Foundation

/// Key & Value Iterator
public struct KeyValueIterator: IteratorProtocol {

    var isEmpty: Bool
    var cursor: Cursor!
    var operation: CursorOperation!
    var nextOperation: CursorOperation!

    public typealias Element = (key: Data, value: Data?)

    public init(cursor: Cursor, operation: CursorOperation, nextOperation: CursorOperation) {
        self.isEmpty = false
        self.cursor = cursor

        // Handle GT query range and at init time simply skip the first key
        var startOperation = operation
        if cursor.query.start != nil && !cursor.query.isGte {
            startOperation = cursor.nextOperation
        }

        self.operation = startOperation
        self.nextOperation = nextOperation
    }

    /// Initialise an empty instance
    public init() {
        self.isEmpty = true
    }

    /// Retrieves next item in the cursor
    ///
    /// - Returns: Key's data or nil if not found
    public mutating func next() -> Element? {
        guard !isEmpty && cursor.isValid else {
            return nil
        }

        do {
            let data = try cursor.get(cursor.query.start, operation)

            if let endKey = cursor.query.end {
                if let dataKey = data?.key {

                    // Cater for reverse ordering
                    let upperBound: ComparisonResult = cursor.query.reversed ? .orderedDescending : .orderedAscending

                    // Compare the returned key with the range end key
                    let result = cursor.compare(endKey, with: dataKey)

                    // If its the same as the end key, include it
                    if cursor.query.isLte && result == .orderedSame {
                        return data

                        // If the next key is above the endKey range
                        // OR, if the query is not LTE but the key is equal to the end range
                    } else if result == upperBound || (!cursor.query.isLte && result == .orderedSame) {
                        return nil
                    }
                }
            }

            // Set current operation to the next operation
            self.operation = nextOperation

            return data
        } catch {
            return nil
        }
    }
}
