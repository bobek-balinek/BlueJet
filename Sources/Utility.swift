//
//  Utility.swift
//  BlueJet
//
//  Created by Przemyslaw Bobak on 18/07/2017.
//
//

import Foundation
#if SWIFT_PACKAGE
    import CLMDB
#endif

/// Convert bytes at given memory pointer to `MDB_val` structure
///
/// - Parameter buf: Pointer to the data
/// - Returns: Instance of MDB_val with given size and bytes data
internal func rawPointerToMdb(_ buf: UnsafeRawBufferPointer) -> MDB_val {
    return MDB_val(
        mv_size: buf.count,
        mv_data: UnsafeMutableRawPointer(mutating: buf.baseAddress)
    )
}

/// Return the in-memory pointer from given MDB_val
///
/// - Parameter mdb: MDB_val instance
/// - Returns: Unsafe pointer
internal func mdbToRawPointer(_ mdb: MDB_val) -> UnsafeRawBufferPointer {
    return UnsafeRawBufferPointer(start: mdb.mv_data, count: mdb.mv_size)
}
