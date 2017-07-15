//
//  DBError.swift
//  BlueJet
//
//  Created by Przemyslaw Bobak on 13/07/2017.
//  Copyright © 2017 Spirograph Limited. All rights reserved.
//

import Foundation
#if SWIFT_PACKAGE
import CLMDB
#endif

//swiftlint:disable cyclomatic_complexity

/// LMDB-operation Error type
public enum DBError: Error {

    // MARK: LMDB Errors

    /// key/data pair already exists
    case keyExists
    /// key/data pair not found (EOF)
    case notFound
    /// Requested page not found - this usually indicates corruption
    case pageNotFound
    /// Located page was wrong type
    case corrupted
    /// Update of meta page failed or environment had fatal error
    case panic
    /// Environment version mismatch
    case versionMismatch
    /// File is not a valid LMDB file
    case invalid
    /// Environment mapsize reached
    case mapFull
    /// Environment maxdbs reached
    case dbsFull
    /// Environment maxreaders reached
    case readersFull
    /// Too many TLS keys in use - Windows only
    case tlsFull
    /// Txn has too many dirty pages
    case txnFull
    /// Cursor stack too deep - internal error
    case cursorFull
    /// Page has not enough space - internal error
    case pageFull
    /// Database contents grew beyond environment mapsize
    case mapResized
    /// Operation and DB incompatible, or DB type changed. This can me
    case incompatible
    /// Invalid reuse of reader locktable slot
    case badReaderSlot
    /// Transaction must abort, has a child, or is invalid
    case badTransaction
    /// Unsupported size of key/DB name/data, or wrong DUPFIXED size
    case badValueSize
    /// The specified DBI was changed unexpectedly
    case badDBI
    /// Unexpected problem - transaction should abort
    case problem

    // MARK: System

    /// Invalid Key/Value parameter
    case invalidParameter

    /// Disk has no free space left
    case outOfDiskSpace

    /// Device has run out of memory
    case outOfMemory

    /// Read/Write error
    case ioError

    /// File permissions error
    case accessViolation

    /// Other status code
    case other(code: Int32)

    /// Initialise with LMDB status code
    ///
    /// - Parameter code: Status code returned by an LMDB's method call
    init(code: Int32) {
        switch code {
        case MDB_KEYEXIST: self = .keyExists
        case MDB_NOTFOUND: self = .notFound
        case MDB_PAGE_NOTFOUND: self = .pageNotFound
        case MDB_CORRUPTED: self = .corrupted
        case MDB_PANIC: self = .panic
        case MDB_VERSION_MISMATCH: self = .versionMismatch
        case MDB_INVALID: self = .invalid
        case MDB_MAP_FULL: self = .mapFull
        case MDB_DBS_FULL: self = .dbsFull
        case MDB_READERS_FULL: self = .readersFull
        case MDB_TLS_FULL: self = .tlsFull
        case MDB_TXN_FULL: self = .txnFull
        case MDB_CURSOR_FULL: self = .cursorFull
        case MDB_PAGE_FULL:  self = .pageFull
        case MDB_MAP_RESIZED: self = .mapResized
        case MDB_INCOMPATIBLE: self = .incompatible
        case MDB_BAD_RSLOT: self = .badReaderSlot
        case MDB_BAD_TXN: self = .badTransaction
        case MDB_BAD_VALSIZE: self = .badValueSize
        case MDB_BAD_DBI: self = .badDBI
        case MDB_PROBLEM: self = .problem

        case EINVAL: self = .invalidParameter
        case ENOSPC: self = .outOfDiskSpace
        case ENOMEM: self = .outOfMemory
        case EIO: self = .ioError
        case EACCES: self = .accessViolation

        default: self = .other(code: code)
        }
    }
}
