//
//  UserModelTests.swift
//  shannonfinaltestSEfix
//
//  Created by Vincent on 02/06/26.
//


import XCTest
import SwiftUI
@testable import shannonfinaltestSEfix

final class UserModelTests: XCTestCase {

    func testRoleDisplayName() {
        // Given
        let admin = UserModel(id: "1", name: "Admin", email: "a@t.com", role: "admin")
        let technician = UserModel(id: "2", name: "Tech", email: "t@t.com", role: "technician")
        
        // Then
        XCTAssertEqual(admin.roleDisplayName, "Admin")
        XCTAssertEqual(technician.roleDisplayName, "Teknisi")
    }
    
    func testAvatarColorConsistency() {
        // Memastikan warna avatar konsisten untuk nama yang sama
        let name = "Budi Doremi"
        let user1 = UserModel(id: "1", name: name, email: "b1@t.com", role: "resident")
        let user2 = UserModel(id: "2", name: name, email: "b2@t.com", role: "resident")
        
        XCTAssertEqual(user1.avatarColor, user2.avatarColor)
    }
}
