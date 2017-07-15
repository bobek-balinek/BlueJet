import XCTest
@testable import DatabaseTests
@testable import EnvironmentTests

XCTMain([
    testCase(DatabaseTests.allTests),
    testCase(EnvironmentTests.allTests)
])
