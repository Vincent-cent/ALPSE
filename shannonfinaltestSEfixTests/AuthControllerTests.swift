//
//  AuthControllerTests.swift
//  shannonfinaltestSEfixTests
//
//  Created by Vincent on 03/06/26.
//

import Testing
import XCTest
@testable import shannonfinaltestSEfix

final class AuthControllerTests: XCTestCase {

    func testFriendlyErrorMappingKnownCodes() {
        let controller = AuthController(shouldFetchCurrentUser: false)

        let emailUsed = NSError(domain: "Auth", code: 17007, userInfo: nil)
        let invalidEmail = NSError(domain: "Auth", code: 17008, userInfo: nil)
        let weakPassword = NSError(domain: "Auth", code: 17026, userInfo: nil)

        XCTAssertEqual(controller.friendlyError(emailUsed), "Email sudah terdaftar. Gunakan email lain.")
        XCTAssertEqual(controller.friendlyError(invalidEmail), "Format email tidak valid.")
        XCTAssertEqual(controller.friendlyError(weakPassword), "Password harus minimal 6 karakter.")
    }

    func testFriendlyErrorUsesLocalizedDescriptionForUnknownCode() {
        let controller = AuthController(shouldFetchCurrentUser: false)
        let error = NSError(domain: "Auth", code: 9999, userInfo: [NSLocalizedDescriptionKey: "Kesalahan umum"])

        XCTAssertEqual(controller.friendlyError(error), "Kesalahan umum")
    }
}
