//
//  CleverVpnFrameworkTests.swift
//  CleverVpnFrameworkTests
//
//  Created by bolin wu on 2024/12/16.
//

import Testing
@testable import CleverVpnFramework

struct CleverVpnFrameworkTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let algorithms = SimpleAlgorithms()
        let fibonacci = algorithms.fibonacci(10)
        let factorial = algorithms.factorial(n: 10)
        #expect(fibonacci == 89)
        #expect(factorial == 3628800)
        
    }

}
