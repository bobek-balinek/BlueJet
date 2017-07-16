//
//  KeyIterator.swift
//  BlueJet
//
//  Created by Przemyslaw Bobak on 16/07/2017.
//
//

import Foundation

/// Key-only Iterator
public struct KeyIterator: IteratorProtocol {

    var isEmpty: Bool
    var cursor: Cursor!
    var lastValue: Element?
    var operation: CursorOperation!
    var nextOperation: CursorOperation!

    public typealias Element = Data

    public init(cursor: Cursor, operation: CursorOperation, nextOperation: CursorOperation) {
        self.isEmpty = false
        self.cursor = cursor
        self.lastValue = cursor.query.startKey?.data()
        self.operation = operation
        self.nextOperation = nextOperation
    }

    /// Initialise an empty instance
    public init() {
        self.isEmpty = true
    }

    /// Retrieves next item in the cursor
    ///
    /// - Returns: Key's data or nil if not found
    public mutating func next() -> Data? {
        guard !isEmpty && cursor.isValid else {
            return nil
        }

        do {
            let data = try cursor.get(cursor.query.startKey, operation)

            if let endKey = cursor.query.endKey {
                if let dataKey = data?.key {

                    // Compare the returned key with the range end key
                    let result = cursor.compare(endKey, with: dataKey)

                    // If its the same as the end key, include it
                    if result == .orderedSame {
                        return dataKey

                    // If the next key is above the endKey range
                    } else if result == .orderedAscending {
                        return nil
                    }
                }
            }

            self.operation = nextOperation
            self.lastValue = data?.key?.data()

            return data?.key ?? nil
        } catch {
            return nil
        }
    }
}
