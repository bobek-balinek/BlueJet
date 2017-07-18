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
    public let start: Slice?

    /// End of the range
    public let end: Slice?

    /// Reverses the order in which results are listed
    public let reversed: Bool

    /// Is less-than or equal
    public let isLte: Bool

    /// Is greater-than or equal
    public let isGte: Bool

    /// Initialise a query with given params
    ///
    /// - Parameters:
    ///   - start: Start of the range
    ///   - end: End of the range
    ///   - reversed: Reverse order
    ///   - database: Database to lookup the keys for
    public init(start: Slice?, end: Slice?, reversed: Bool, database: Database) {
        self.start = start
        self.end = end
        self.reversed = reversed
        self.database = database
        self.isLte = true
        self.isGte = true
    }

    /// Initialise with more precise range keys
    ///
    /// - Parameters:
    ///   - gte: Greater-than or equal to the key
    ///   - gt: Greater-than the key
    ///   - lte: Lower-than or equal to the key
    ///   - lt: Lower-than the key
    ///   - reversed: Reverse order
    ///   - database: Database to lookup the keys for
    public init(
        gte: Slice? = nil,
        gt: Slice? = nil,
        lte: Slice? = nil,
        lt: Slice? = nil,
        reversed: Bool,
        database: Database
    ) {
        // Favour lte over lt if both are present
        self.start = gt ?? gte
        // Favour gte over gt if both are present
        self.end = lt ?? lte
        self.reversed = reversed
        self.database = database
        self.isGte = gte != nil
        self.isLte = lte != nil
    }
}
