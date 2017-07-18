//
//  Database.swift
//  BlueJet
//
//  Created by Przemyslaw Bobak on 14/07/2017.
//  Copyright © 2017 Spirograph Limited. All rights reserved.
//

import Foundation
#if SWIFT_PACKAGE
import CLMDB
#endif

/// Database
public class Database {

    /// Database flags
    public struct Flags: OptionSet {
        /// Raw value
        public let rawValue: Int32

        /// Initialise with LMDB
        ///
        /// - Parameter rawValue: Status code received from LMDB
        public init(rawValue: Int32) { self.rawValue = rawValue}

        /// use reverse string keys
        public static let reverseKey = Flags(rawValue: MDB_FIXEDMAP)
        /// use sorted duplicates
        public static let duplicateSort = Flags(rawValue: MDB_NOSUBDIR)
        /// numeric keys in native byte order, either unsigned int or #mdb_size
        public static let integerKey = Flags(rawValue: MDB_NOSYNC)
        /// with #MDB_DUPSORT, sorted dup items have fixed size
        public static let duplicateFixed = Flags(rawValue: MDB_RDONLY)
        /// with #MDB_DUPSORT, dups are #MDB_INTEGERKEY-style integers
        public static let integerDuplicate = Flags(rawValue: MDB_NOMETASYNC)
        /// with #MDB_DUPSORT, use reverse string dups
        public static let reverseDuplicate = Flags(rawValue: MDB_WRITEMAP)
        /// create DB if not already existing
        public static let create = Flags(rawValue: MDB_CREATE)
    }

    /// Flags to specify `mdb_put` behaviour
    public struct PutFlags: OptionSet {
        /// Raw value
        public let rawValue: Int32

        /// Initialise with LMDB
        ///
        /// - Parameter rawValue: Status code received from LMDB
        public init(rawValue: Int32) { self.rawValue = rawValue}

        /// Dont duplicate key/value pairs
        public static let noDuplicateData = PutFlags(rawValue: MDB_NODUPDATA)

        /// Don't override existing value
        public static let noOverwrite = PutFlags(rawValue: MDB_NOOVERWRITE)

        /// Just reserve space for data, don't copy it. Return a pointer to the reserved space.
        public static let reserve = PutFlags(rawValue: MDB_RESERVE)

        /// Data is being appended, don't split full pages
        public static let append = PutFlags(rawValue: MDB_APPEND)

        /// Duplicate data is being appended, don't split full pages
        public static let appendDuplicate = PutFlags(rawValue: MDB_APPENDDUP)
    }

    /// Flags to specify `mdb_drop` behaviour
    private struct DropFlag: OptionSet {
        /// Raw value
        let rawValue: Int32

        /// Initialise with LMDB
        ///
        /// - Parameter rawValue: Status code received from LMDB
        init(rawValue: Int32) { self.rawValue = rawValue }

        static let empty = DropFlag(rawValue: 0)
        static let delete = DropFlag(rawValue: 1)
    }

    /// Pointer to the database
    internal private(set) var pointer: MDB_dbi = 0

    /// Environment containing the database
    internal private(set) var environment: Environment

    /// Initialise a database
    ///
    /// - Parameters:
    ///   - name: Name of the database
    ///   - environment: Environment containing the database
    ///   - flags: Optional flagss
    /// - throws: Operation error. See `DBError`.
    public init(name: String?, environment: Environment, flags: Flags = []) throws {
        self.environment = environment

        do {
            try execute({ transaction in
                return try validate(mdb_dbi_open(
                    transaction.pointer,
                    name?.cString(using: .utf8),
                    UInt32(flags.rawValue),
                    &pointer
                ))
            })
        } catch {
            throw error
        }
    }

    deinit {
        mdb_dbi_close(environment.pointer, pointer)
    }

    /// Close the database handle.
    /// Refer to `mdb_dbi_close` for usage.
    public func close() {
        mdb_dbi_close(environment.pointer, pointer)
    }

    /// Sync any in-memory data to the disk.
    /// Refer to `mdb_env_sync` for usage.
    ///
    /// - throws: Operation error. See `DBError`.
    public func sync() throws {
        do {
            return try validate(mdb_env_sync(environment.pointer, 1))
        } catch {
            throw error
        }
    }

    /// Drop/delete the database
    ///
    /// - throws: Operation error. See `DBError`.
    public func drop() throws {
        do {
            try execute({ transaction in
                return try validate(mdb_drop(transaction.pointer, pointer, DropFlag.delete.rawValue))
            })
        } catch {
            throw error
        }
    }

    /// Empty the database
    ///
    /// - throws: Operation error. See `DBError`.
    public func empty() throws {
        do {
            try execute({ transaction in
                return try validate(mdb_drop(transaction.pointer, pointer, DropFlag.empty.rawValue))
            })
        } catch {
            throw error
        }
    }

    // MARK: Transaction blocks

    /// Execute given block within a read/write transaction
    ///
    /// - Parameter closure: Closure to execute containing calls to LMDB
    /// - throws: Operation error. See `DBError`.
    func execute(_ closure: Transaction.Closure) throws {
        var txn = try Transaction(environment: environment)
        return try txn.run(closure: closure)
    }

    /// Execute given block within a read/write transaction
    ///
    /// - Parameter closure: Closure to execute containing calls to LMDB
    /// - throws: Operation error. See `DBError`.
    func beginWrite(_ closure: Transaction.Closure) throws {
        var txn = try Transaction(environment: environment)
        return try txn.run(closure: closure)
    }

    /// Execute given block within a read-only transaction
    ///
    /// - Parameter closure: Closure to execute containing calls to LMDB
    /// - throws: Operation error. See `DBError`.
    func beginRead(_ closure: Transaction.Closure) throws {
        var txn = try Transaction(environment: environment, parent: nil, flags: [.readOnly])
        return try txn.run(closure: closure)
    }

    // MARK: Data manipulation

    /// Get value for given key
    ///
    /// - Parameter key: Key to lookup the database with
    /// - Returns: Data instance if the value exists or nil if non-existing
    /// - throws: Operation error. See `DBError`.
    public func get(_ key: Slice) throws -> Data? {
        // The database will manage the memory for the returned value.
        // http://104.237.133.194/doc/group__mdb.html#ga8bf10cd91d3f3a83a34d04ce6b07992d
        var value: MDB_val = MDB_val()
        var status: Int32 = MDB_SUCCESS

        do {
            try beginRead({ transaction in
                return try key.slice({ (key: UnsafeRawBufferPointer) in
                    var keyValue = rawPointerToMdb(key)

                    if keyValue.mv_size == 0 {
                        throw DBError.invalidParameter
                    }

                    status = mdb_get(transaction.pointer, pointer, &keyValue, &value)
                })
            })

            if status == MDB_NOTFOUND || value.mv_size == 0 {
                return nil
            }

            return Data(data: mdbToRawPointer(value))
        } catch let error {
            throw error
        }
    }

    /// Put given key/value pair into the database
    ///
    /// - Parameter key: Key to lookup the database with
    /// - Parameter value: Raw data value to save. If no data is given, an empty key/value paid will be saved.
    /// - Parameter flags: Optional flags to execute the `mdb_put` method with
    /// - throws: Operation error. See `DBError`.
    public func put(_ key: Slice, _ value: Data?, flags: PutFlags = []) throws {
        /// If no data has been passed, lets save an empty value
        let val = value ?? Data()

        do {
            try beginWrite({ (transaction) in
                try key.slice({ (keyPointer: UnsafeRawBufferPointer) in
                    try val.slice({ (valuePointer: UnsafeRawBufferPointer) in
                        var mdbKey = rawPointerToMdb(keyPointer)
                        var mdbValue = rawPointerToMdb(valuePointer)

                        if mdbKey.mv_size == 0 {
                            throw DBError.invalidParameter
                        }

                        return try self.validate(mdb_put(
                            transaction.pointer,
                            pointer,
                            &mdbKey,
                            &mdbValue,
                            UInt32(flags.rawValue)
                        ))
                    })
                })
            })
        } catch let error {
            throw error
        }
    }

    /// Delete given key/value paid
    ///
    /// - Parameter key: Keuy to look the database with
    /// - throws: Operation error. See `DBError`.
    public func delete(_ key: Slice) throws {
        do {
            try beginWrite({ (transaction) in
                try key.slice({ (keyPointer) in
                    var mdbKey = rawPointerToMdb(keyPointer)

                    return try self.validate(mdb_del(
                        transaction.pointer,
                        pointer,
                        &mdbKey, nil
                    ))
                })
            })
        } catch let error {
            throw error
        }
    }

    // MARK: - Iterators

    /// Create a new key iterator for given params
    ///
    /// - Parameters:
    ///   - start: Key to start the iteration with
    ///   - end: Key to end the iteration at
    ///   - reversed: Reverse order
    /// - Returns: Instance of the `KeySequence`
    func keyIterator(start: String? = nil, end: String? = nil, reversed: Bool = false) -> KeySequence {
        let query = Query(start: start, end: end, reversed: reversed, database: self)
        return KeySequence(query: query)
    }

    /// Create a new key+value iterator for given params
    ///
    /// - Parameters:
    ///   - start: Key to start the iteration with
    ///   - end: Key to end the iteration at
    ///   - reversed: Reverse order
    /// - Returns: Instance of the `KeyValueSequence`
    func keyValueIterator(start: String? = nil, end: String? = nil, reversed: Bool = false) -> KeyValueSequence {
        let query = Query(start: start, end: end, reversed: reversed, database: self)
        return KeyValueSequence(query: query)
    }

    /// Get a range of keys and values.
    /// Typically used with more precise queries
    /// NOTE: LTE/GTE values is favoured over LT/GT if both pairs are given
    ///
    /// - Parameters:
    ///   - gte: Greater-than or equal to the key
    ///   - gt: Greater-than the key
    ///   - lte: Lower-than or equal to the key
    ///   - lt: Lower-than the key
    ///   - reversed: Reverse order
    /// - Returns: Instance of `KeyValueSequence`
    func range(
        gte: Slice? = nil,
        gt: Slice? = nil,
        lte: Slice? = nil,
        lt: Slice? = nil,
        reversed: Bool = false
    ) -> KeyValueSequence {
        let query = Query(gte: gte, gt: gte, lte: lte, lt: lte, reversed: reversed, database: self)
        return KeyValueSequence(query: query)
    }

    // MARK: - Class methods

    /// Create a database within given environment
    ///
    /// - Parameters:
    ///   - name: Name of the database
    ///   - environment: Environment to contain the database
    ///   - flags: Database flags
    /// - Returns: Newly created Database
    /// - throws: Operation error. See `DBError`.
    public class func create(name: String, environment: Environment, flags: Flags = []) throws -> Database {
        return try Database(name: name, environment: environment, flags: flags.union(.create))
    }

    // MARK: Private

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
