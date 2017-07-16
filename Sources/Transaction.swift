//
//  Transaction.swift
//  BlueJet
//
//  Created by Przemyslaw Bobak on 14/07/2017.
//  Copyright © 2017 Spirograph Limited. All rights reserved.
//

import Foundation
#if SWIFT_PACKAGE
import CLMDB
#endif

/// Transaction
public struct Transaction {

    public typealias Closure = ((Transaction) throws -> Void)

    /// Transaction flags
    public struct Flags: OptionSet {
        /// Raw value
        public let rawValue: Int32

        /// Initialise with LMDB
        ///
        /// - Parameter rawValue: Status code received from LMDB
        public init(rawValue: Int32) { self.rawValue = rawValue }

        /// read-only mode
        public static let readOnly = Flags(rawValue: MDB_RDONLY)
    }

    /// Pointer to the transaction instance
    internal private(set) var pointer: OpaquePointer?

    /// Initialises a read/write transaction
    ///
    /// - Parameters:
    ///   - environment: Environment to operate in
    ///   - parent: Parent transaction if applicable
    ///   - flags: transaction flags, i.e. read only
    /// - throws: Operation error. See `DBError`.
    init(environment: Environment, parent: Transaction? = nil, flags: Transaction.Flags = []) throws {
        try validate(mdb_txn_begin(environment.pointer, parent?.pointer, UInt32(flags.rawValue), &pointer))
    }

    /// Run transaction with given block
    ///
    /// - Parameter closure: Transaction block. Can throw an error
    /// - throws: Operation error. See `DBError`.
    public mutating func run(closure: Closure) throws {
        guard pointer != nil else {
            throw DBError.badTransaction
        }

        defer {
            pointer = nil
        }

        do {
            try closure(self)
            try commit()
        } catch let error {
            abort()
            throw error
        }
    }

    /// Commit operations in this transaction
    ///
    /// - throws: Operation error. See `DBError`.
    public mutating func commit() throws {
        guard pointer != nil else {
            throw DBError.badTransaction
        }

        defer {
            pointer = nil
        }

        return try validate(mdb_txn_commit(pointer))
    }

    /// Reset read-only transaction
    public func reset() {
        mdb_txn_reset(pointer)
    }

    /// Abort given transaction
    public func abort() {
        mdb_txn_abort(pointer)
    }

    /// Renew a read-only transaction
    public func renew() {
        mdb_txn_renew(pointer)
    }

    public func compare(_ key: Slice, with otherKey: Slice, in database: Database) -> ComparisonResult? {
        var keyValue = key.mdbValue()
        var otherKeyValue = key.mdbValue()
        let value = Int(mdb_cmp(pointer, database.pointer, &keyValue, &otherKeyValue))

        return ComparisonResult(rawValue: value)
    }

    public func cursor(query: Query) -> Cursor {
        return Cursor(transaction: self, query: query)
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
}
