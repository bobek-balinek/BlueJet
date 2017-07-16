//
//  Query.swift
//  BlueJet
//
//  Created by Przemyslaw Bobak on 15/07/2017.
//
//

import Foundation
#if SWIFT_PACKAGE
import CLMDB
#endif

/// Query structure
public struct Query {

    /// Database to query the data against
    public let database: Database

    /// Start of the range
    public let startKey: Slice?

    /// End of the range
    public let endKey: Slice?

    /// Reverses the order in which results are listed
    public let reversed: Bool

    // TODO: Add lte/gte options
    // public let includeEndRange: Bool

    /// Initialise a query with given params
    ///
    /// - Parameters:
    ///   - startKey: Start of the range
    ///   - endKey: End of the range
    ///   - reversed: Reverse order
    ///   - database: Database to lookup the keys for
    public init(startKey: Slice?, endKey: Slice?, reversed: Bool, database: Database) {
        self.startKey = startKey
        self.endKey = endKey
        self.reversed = reversed
        self.database = database
    }
}
