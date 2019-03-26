//
//  Slice.swift
//  BlueJet
//
//  Created by Przemyslaw Bobak on 14/07/2017.
//
//

import Foundation
#if SWIFT_PACKAGE
import CLMDB
#endif

/// Slice protocol
///
/// It is used to convert Swift value types to Data as well as obtain memory pointer and raw bytes.
public protocol Slice {

    /// Transform to given type using pointer/bytes transformation block
    ///
    /// - Parameter block: Closure transforming the bytes/points
    /// - Returns: result of the block casted to given type
    /// - Throws: Data conversion Error
    func slice<ResultType>(_ block: (UnsafeRawBufferPointer) throws -> ResultType) rethrows -> ResultType

    /// Return Data instance
    ///
    /// - Returns: Data of self
    func data() -> Data
}

extension Slice {
    public func mdbValue() -> MDB_val {
        let nsData: NSData = NSData(data: data())
        let rawPtr = UnsafeMutableRawPointer(mutating: nsData.bytes)

        return MDB_val(mv_size: nsData.length, mv_data: rawPtr)
    }
}

// MARK: - Data extension

extension Data: Slice {

    /// Transform to given type using pointer/bytes transformation block
    ///
    /// - Parameter block: Closure transforming the bytes/points
    /// - Returns: result of the block casted to given type
    /// - Throws: Data conversion Error
    public func slice<ResultType>(_ block: (UnsafeRawBufferPointer) throws -> ResultType) rethrows -> ResultType {
        return try self.withUnsafeBytes({ (typedPtr: UnsafePointer<UInt8>) -> ResultType in
            return try block(UnsafeRawBufferPointer.init(start: typedPtr, count: self.count))
        })
    }

    /// Return Data instance
    ///
    /// - Returns: Data of self
    public func data() -> Data {
        return self
    }

    /// Initialise with a in-memory pointer
    ///
    /// - Parameter data: Instance of the in-memory poointer
    public init?(data: UnsafeRawBufferPointer) {
        // If memory has been wrongly allocated, just return nil
        guard data.baseAddress != nil else {
            return nil
        }

        // This copies the bytes out immediately.
        self = Data(bytes: data.baseAddress!, count: data.count)
    }
}

// MARK: - String extension

extension String: Slice {

    /// Transform to given type using pointer/bytes transformation block
    ///
    /// - Parameter block: Closure transforming the bytes/points
    /// - Returns: result of the block casted to given type
    /// - Throws: Data conversion Error
    public func slice<ResultType>(_ block: (UnsafeRawBufferPointer) throws -> ResultType) rethrows -> ResultType {
        return try data().slice(block)
    }

    /// Return Data instance
    ///
    /// - Returns: Data of self
    public func data() -> Data {
        return data(using: .utf8)!
    }
}
