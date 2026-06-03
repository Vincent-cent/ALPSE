//
//  ReportControllerTests.swift
//  shannonfinaltestSEfixTests
//
//  Created by Vincent on 03/06/26.
//

import XCTest
import FirebaseFirestore
import Combine
@testable import shannonfinaltestSEfix

final class ReportControllerTests: XCTestCase {

    func testParseReportDecodesDataAndDefaults() {
        let controller = ReportController(shouldListen: false)

        let expectedData = Data("gambar".utf8)
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let payload: [String: Any] = [
            "reportId": "R-001",
            "title": "Lampu Mati",
            "category": "Fasilitas Rusak",
            "location": "Blok A",
            "description": "Lampu koridor mati",
            "image_base64": expectedData.base64EncodedString(),
            "date": Timestamp(date: date),
            "submittedByUserId": "U-1",
            "assignedTechnicianId": "T-1",
            "assignedTechnicianName": "Budi"
        ]

        let report = controller.parseReport(from: payload)

        XCTAssertNotNil(report)
        XCTAssertEqual(report?.reportId, "R-001")
        XCTAssertEqual(report?.status, "Pending")
        XCTAssertEqual(report?.isUrgent, false)
        XCTAssertEqual(report?.needsAdminReview, false)
        XCTAssertEqual(report?.imageData, expectedData)
        XCTAssertNil(report?.proofImageData)
        XCTAssertEqual(report?.date, date)
    }

    func testComputedReportFilters() {
        let controller = ReportController(shouldListen: false)
        controller.reports = [
            makeReport(id: "R1", status: "Pending", needsReview: false, submittedBy: "U1", assignedTo: ""),
            makeReport(id: "R2", status: "Pending", needsReview: true, submittedBy: "U1", assignedTo: "T1"),
            makeReport(id: "R3", status: "In Progress", needsReview: false, submittedBy: "U2", assignedTo: "T1"),
            makeReport(id: "R4", status: "Completed", needsReview: false, submittedBy: "U2", assignedTo: "T2")
        ]

        XCTAssertEqual(controller.pendingReports.count, 2)
        XCTAssertEqual(controller.needsReviewReports.count, 1)
        XCTAssertEqual(controller.inProgressReports.count, 1)
        XCTAssertEqual(controller.completedReports.count, 1)
        XCTAssertEqual(controller.reports(forUser: "U1").count, 2)
        XCTAssertEqual(controller.reports(assignedTo: "T1").count, 2)
        XCTAssertEqual(controller.getReportsByStatus("Completed").count, 1)
    }
}

private func makeReport(
    id: String,
    status: String,
    needsReview: Bool,
    submittedBy: String,
    assignedTo: String
) -> ReportModel {
    ReportModel(
        reportId: id,
        title: "Judul",
        category: "Kategori",
        location: "Lokasi",
        description: "Deskripsi",
        imageData: nil,
        proofImageData: nil,
        status: status,
        date: Date(),
        isUrgent: false,
        submittedByUserId: submittedBy,
        assignedTechnicianId: assignedTo,
        assignedTechnicianName: assignedTo.isEmpty ? "" : "Teknisi",
        needsAdminReview: needsReview
    )
}
