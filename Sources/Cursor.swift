//
//  Cursor.swift
//  BlueJet
//
//  Created by Przemyslaw Bobak on 15/07/2017.
//
//

import Foundation
#if SWIFT_PACKAGE
import CLMDB
#endif

/// Cursor class
public class Cursor {

    /// Type alias for a Key/Value tuple
    public typealias KeyValuePair = (key: Data, value: Data?)

    /// Query used to position cursor at
    public let query: Query

    /// Pointer to the database instance
    internal private(set) var pointer: OpaquePointer?

    /// Last occurred error. Used to check validity of the cursor
    internal private(set) var lastError: Error?

    /// Initialise a curosr within given read-only operation
    ///
    /// - Parameters:
    ///   - transaction: Read-only transaction
    ///   - query: Query to setup cursor behaviour
    public init(transaction: Transaction, query: Query) {
        self.query = query

        do {
            try setup(transaction)
            _ = try get(query.start, operation)
        } catch {
            lastError = error
        }
    }

    deinit {
        if pointer != nil {
            mdb_cursor_close(pointer)
        }
    }

    /// Valid cursor has not received any operation errors
    var isValid: Bool {
        return lastError == nil
    }

    /// Initial operation for given cursor
    /// When start key is not specified it will go to the start/end of the database
    /// Otherwise the cursor will be set at the start key
    var operation: CursorOperation {
        guard query.start == nil else {
            return .set
        }

        return query.reversed ? .last : .first
    }

    /// Next operation is used when iterating over key/value pairs
    var nextOperation: CursorOperation {
        return query.reversed ? .previous : .next
    }

    /// Get item from a database
    ///
    /// - Parameters:
    ///   - key: The key to search for in the database
    ///   - operation: A cursor operation
    /// - Returns: Key/Value pair
    /// - throws: Operation error. See `DBError`.
    public func get(_ key: Slice?, _ operation: CursorOperation) throws -> KeyValuePair? {
        var keyValue: MDB_val = key?.mdbValue() ?? MDB_val()
        var value: MDB_val = MDB_val()
        let op: MDB_cursor_op = MDB_cursor_op(rawValue: operation.rawValue)

        do {
            guard
                try validateGet(mdb_cursor_get(pointer, &keyValue, &value, op)) == MDB_SUCCESS,
                let key = Data(data: mdbToRawPointer(keyValue)) else {
                return nil
            }

            return (
                key,
                Data(data: mdbToRawPointer(value))
            )
        } catch let error {
            throw error
        }
    }

    /// Compare two keys using byte-comparison. 
    /// This is particularly useful when dealing with strings
    ///
    /// - Parameters:
    ///   - key: A key to compare with
    ///   - otherKey: Another key to compare
    /// - Returns: `ComparisonResult` value  
    public func compare(_ key: Slice, with otherKey: Slice) -> ComparisonResult? {
        return key.slice { (aPointer) in
            return otherKey.slice { (bPointer) in
                var cmp = memcmp(aPointer.baseAddress!, bPointer.baseAddress!, min(aPointer.count, bPointer.count))

                if cmp == 0 {
                    cmp = Int32(aPointer.count - bPointer.count)
                }

                return ComparisonResult(rawValue: (cmp < 0) ? -1 : (cmp > 0) ? 1 : 0)!
            }
        }
    }

    // MARK: - Internal

    /// Setup cursor or renew it
    ///
    /// - Parameter transaction: Transaction is required
    /// - throws: Operation error. See `DBError`.
    internal func setup(_ transaction: Transaction) throws {
        guard pointer == nil else {
            try validate(mdb_cursor_renew(transaction.pointer, pointer))
            return
        }

        try validate(mdb_cursor_open(transaction.pointer, query.database.pointer, &pointer))
    }

    /// Check if given status code is valid
    ///
    /// - Parameter statusCode: Status code returned from invoking LMDB functions
    /// - throws: Operation error. See `DBError`.
    internal func validate(_ statusCode: Int32) throws {
        if statusCode != MDB_SUCCESS {
            throw DBError(code: statusCode)
        }
    }

    /// Check if given status code is valid or not found
    /// Throws an error if otherwise
    ///
    /// - Parameter statusCode: Status code returned from invoking LMDB functions
    /// - throws: Operation error. See `DBError`.
    internal func validateGet(_ statusCode: Int32) throws -> Int32? {
        if statusCode != MDB_SUCCESS && statusCode != MDB_NOTFOUND {
            throw DBError(code: statusCode)
        }

        if statusCode == MDB_NOTFOUND {
            return nil
        }

        return statusCode
    }
}
