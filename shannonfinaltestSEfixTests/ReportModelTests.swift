//
//  ReportModelTests.swift
//  shannonfinaltestSEfix
//
//  Created by Vincent on 02/06/26.
//


import XCTest
import SwiftUI
@testable import shannonfinaltestSEfix // Ganti dengan nama modul proyek Anda

final class ReportModelTests: XCTestCase {

    func testStatusDisplayName() {
        // Persiapan data (Given)
        let reportPending = ReportModel(
            reportId: "1", title: "Test", category: "C1", location: "L1",
            description: "D1", imageData: nil, proofImageData: nil,
            status: "Pending", date: Date(), isUrgent: false,
            submittedByUserId: "U1", assignedTechnicianId: "",
            assignedTechnicianName: "", needsAdminReview: false
        )
        
        let reportCompleted = ReportModel(
            reportId: "2", title: "Test 2", category: "C2", location: "L2",
            description: "D2", imageData: nil, proofImageData: nil,
            status: "Completed", date: Date(), isUrgent: false,
            submittedByUserId: "U1", assignedTechnicianId: "",
            assignedTechnicianName: "", needsAdminReview: false
        )

        // Verifikasi (Then)
        XCTAssertEqual(reportPending.statusDisplayName, "Menunggu")
        XCTAssertEqual(reportCompleted.statusDisplayName, "Selesai")
        XCTAssertEqual(reportPending.statusColor, .orange)
        // Mengecek warna hijau custom untuk 'Completed'
        XCTAssertEqual(reportCompleted.statusColor, Color(red: 0.2, green: 0.6, blue: 0.2))
    }
}
