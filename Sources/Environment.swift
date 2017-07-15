//
//  Environment.swift
//  BlueJet
//
//  Created by Przemyslaw Bobak on 13/07/2017.
//  Copyright © 2017 Spirograph Limited. All rights reserved.
//

import Foundation
#if SWIFT_PACKAGE
import CLMDB
#endif

/// Environment main class 
public class Environment {

    /// Environment flags
    public struct Flags: OptionSet {
        /// Raw value
        public let rawValue: Int32

        /// Initialise with LMDB
        ///
        /// - Parameter rawValue: Status code received from LMDB
        public init(rawValue: Int32) { self.rawValue = rawValue}

        /// mmap at a fixed address (experimental)
        public static let fixedMap = Flags(rawValue: MDB_FIXEDMAP)
        /// no environment directory
        public static let noSubDir = Flags(rawValue: MDB_NOSUBDIR)
        /// don't fsync after commit
        public static let noSync = Flags(rawValue: MDB_NOSYNC)
        /// read only
        public static let readOnly = Flags(rawValue: MDB_RDONLY)
        /// don't fsync metapage after commit
        public static let noMetaSync = Flags(rawValue: MDB_NOMETASYNC)
        /// use writable mmap
        public static let writeMap = Flags(rawValue: MDB_WRITEMAP)
        /// use asynchronous msync when #MDB_WRITEMAP is used
        public static let mapAsync = Flags(rawValue: MDB_MAPASYNC)
        /// tie reader locktable slots to #MDB_txn objects instead of to threads
        public static let noTLS = Flags(rawValue: MDB_NOTLS)
        /// don't do any locking, caller must manage their own locks
        public static let noLock = Flags(rawValue: MDB_NOLOCK)
        /// don't do readahead (no effect on Windows)
        public static let noReadahead = Flags(rawValue: MDB_NORDAHEAD)
        /// don't initialize malloc'd memory before writing to datafile
        public static let noMemoryInit = Flags(rawValue: MDB_NOMEMINIT)
    }

    /// Environment configuration
    public struct Configuration {

        /// Set of flags
        public let flags: Flags

        /// Maximum number of databases within the environment
        public let maximumDBs: UInt32

        /// Maximum number of threads/reader slots
        public let maxReaders: UInt32

        /// The size of the memory map. The value should be a multiple of the OS page size.
        public let mapSize: size_t

        /// Initialise Configuration
        ///
        /// - Parameters:
        ///   - flags: Environment flags
        ///   - maximumDBs: Maximum number of databases
        ///   - maxReaders: Maximnum number of readers
        ///   - mapSize: Memory map size
        public init(flags: Flags, maximumDBs: UInt32, maxReaders: UInt32, mapSize: size_t) {
            self.flags = flags
            self.maximumDBs = maximumDBs
            self.maxReaders = maxReaders
            self.mapSize = mapSize
        }

        /// Default configuration
        public static var `default`: Configuration {
            return Configuration(
                flags: [],
                maximumDBs: 32,
                maxReaders: 126,
                mapSize: 10485760
            )
        }
    }

    /// Pointer to the database instance
    internal private(set) var pointer: OpaquePointer?

    /// Initialise an Environment with 0 or more databases
    ///
    /// - Parameters:
    ///   - path: Local path to the database file. The folder and the file should exist and be readable.
    ///   - flags: Set with environment flags
    ///   - maxDBs: Maximum number of databases within the environment
    ///   - maxReaders:
    ///   - mapSize: The size of the memory map. The value should be a multiple of the OS page size.
    /// - throws: Operation error. See `DBError`.
    public init(path: String, configuration: Configuration = .default) throws {
        do {
            try validate(mdb_env_create(&pointer))

            /// Unwrap and set the databases
            try set(databases: configuration.maximumDBs)

            /// Unwrap and set the readers
            try set(readers: configuration.maxReaders)

            /// Unwrap and set the memory map size
            try set(memoryMap: configuration.mapSize)

            /// Open the environment
            try open(path: path, flags: configuration.flags)
        } catch let error {
            throw error
        }
    }

    deinit {
        close()
    }

    /// Close the environment
    public func close() {
        mdb_env_close(pointer)
    }

    // MARK: Internal

    /// Initialise environment at given path with set flags
    ///
    /// - Parameters:
    ///   - path: Local path to the database file. The folder and the file should exist and be readable.
    ///   - flags: Set with environment flags
    /// - Throws: Operation error. See `DBError`.
    internal func open(path: String, flags: Flags) throws {
        let DEFAULT_FILE_MODE: mode_t = S_IRWXU | S_IRGRP | S_IXGRP | S_IROTH | S_IXOTH // 755
        return try validate(mdb_env_open(
            pointer,
            path.cString(using: .utf8),
            UInt32(flags.rawValue),
            DEFAULT_FILE_MODE
        ))
    }

    /// Set the maximum number of databases for the environment
    ///
    /// - Parameter count: Number of maximum allowed databases for this environment
    /// - Throws: Operation error. See `DBError`.
    internal func set(databases count: UInt32) throws {
        return try validate(mdb_env_set_maxdbs(pointer, MDB_dbi(count)))
    }

    /// Set the maximum number of readers/threads for the environment
    ///
    /// - Parameter count: Maximum number of threads/reader slots
    /// - Throws: Operation error. See `DBError`.
    internal func set(readers count: UInt32) throws {
        return try validate(mdb_env_set_maxreaders(pointer, count))
    }

    /// Set the memory map size
    ///
    /// - Parameter size: The size of the memory map. The value should be a multiple of the OS page size.
    /// - Throws: Operation error. See `DBError`.
    internal func set(memoryMap size: size_t) throws {
        return try validate(mdb_env_set_mapsize(pointer, size))
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
