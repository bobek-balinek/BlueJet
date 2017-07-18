//
//  CursorOperation.swift
//  BlueJet
//
//  Created by Przemyslaw Bobak on 15/07/2017.
//
//

import Foundation
#if SWIFT_PACKAGE
import CLMDB
#endif

/// Cursor Get Operations
public struct CursorOperation {
    /// Raw value
    public let rawValue: UInt32

    /// Initialise with `MDB_cursor_op`
    ///
    /// - Parameter rawValue: Status code received from LMDB
    public init(_ rawValue: UInt32) { self.rawValue = rawValue}

    // MARK: - First

    /// Positions the cursor at first key/value item
    public static let first: CursorOperation = CursorOperation(MDB_FIRST.rawValue)

    /// Position at first data item of current key.
    public static let firstDup: CursorOperation = CursorOperation(MDB_FIRST_DUP.rawValue)

    // MARK: - Last

    /// Position at last key/data item
    public static let last: CursorOperation = CursorOperation(MDB_LAST.rawValue)

    /// Position at last data item of current key.
    /// Only for #MDB_DUPSORT
    public static let lastDup: CursorOperation = CursorOperation(MDB_LAST_DUP.rawValue)

    // MARK: - Next

    /// Position at next data item
    public static let next: CursorOperation = CursorOperation(MDB_NEXT.rawValue)

    /// Position at next data item of current key.
    /// Only for #MDB_DUPSORT
    public static let nextDup: CursorOperation = CursorOperation(MDB_NEXT_DUP.rawValue)

    /// Position at first data item of next key
    public static let nextNoDup: CursorOperation = CursorOperation(MDB_NEXT_NODUP.rawValue)

    /// Return key and up to a page of duplicate data items from next cursor position.
    /// Move cursor to prepare for #MDB_NEXT_MULTIPLE.
    /// Only for #MDB_DUPSORT
    public static let nextMultiple: CursorOperation = CursorOperation(MDB_NEXT_MULTIPLE.rawValue)

    // MARK: - Previous

    /// Position at previous data item
    public static let previous: CursorOperation = CursorOperation(MDB_PREV.rawValue)

    /// Position at previous data item of current key.
    /// Only for #MDB_DUPSORT
    public static let previousDup: CursorOperation = CursorOperation(MDB_PREV_DUP.rawValue)

    /// Position at last data item of previous key
    public static let previousNoDup: CursorOperation = CursorOperation(MDB_PREV_NODUP.rawValue)

    /// Position at previous page and return key and up to a page of duplicate data items.
    /// Only for #MDB_DUPFIXED
    public static let previousMultiple: CursorOperation = CursorOperation(MDB_PREV_NODUP.rawValue)

    // MARK: - Get

    /// Position at key/data pair.
    /// Only for #MDB_DUPSORT
    public static let getBoth: CursorOperation = CursorOperation(MDB_GET_BOTH.rawValue)

    /// Position at key, nearest data.
    /// Only for #MDB_DUPSORT
    public static let getBothRange: CursorOperation = CursorOperation(MDB_GET_BOTH_RANGE.rawValue)

    /// Return key/data at current cursor position
    public static let getCurrent: CursorOperation = CursorOperation(MDB_GET_CURRENT.rawValue)

    /// Return key and up to a page of duplicate data items from current cursor position.
    /// Move cursor to prepare for #MDB_NEXT_MULTIPLE.
    /// Only for #MDB_DUPSORT
    public static let getMultiple: CursorOperation = CursorOperation(MDB_GET_MULTIPLE.rawValue)

    // MARK: - Set

    /// Position at specified key
    public static let set: CursorOperation = CursorOperation(MDB_SET.rawValue)

    /// Position at specified key, return key + data
    public static let setKey: CursorOperation = CursorOperation(MDB_SET_KEY.rawValue)

    /// Position at first key greater than or equal to specified key
    public static let setRange: CursorOperation = CursorOperation(MDB_SET_RANGE.rawValue)
}
