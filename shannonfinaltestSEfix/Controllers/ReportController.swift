//
//  ReportController.swift
//

import Foundation
import SwiftUI
import FirebaseFirestore
import Combine

class ReportController: ObservableObject {
    @Published var reports: [ReportModel] = []
    @Published var isLoading = false

    private let db = Firestore.firestore()

    init() {
        listenToAllReports()
    }

    func listenToAllReports() {
        db.collection("reports")
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let docs = snapshot?.documents else { return }
                DispatchQueue.main.async {
                    self.reports = docs.compactMap { self.parseReport(from: $0.data()) }
                }
            }
    }

    private func parseReport(from data: [String: Any]) -> ReportModel? {
        guard let reportId = data["reportId"] as? String else { return nil }
        let title        = data["title"]       as? String ?? ""
        let category     = data["category"]    as? String ?? ""
        let location     = data["location"]    as? String ?? ""
        let description  = data["description"] as? String ?? ""
        let status       = data["status"]      as? String ?? "Pending"
        let isUrgent     = data["isUrgent"]    as? Bool   ?? false
        let submittedBy  = data["submittedByUserId"]       as? String ?? ""
        let assignedId   = data["assignedTechnicianId"]    as? String ?? ""
        let assignedName = data["assignedTechnicianName"]  as? String ?? ""
        let needsAdminReview = data["needsAdminReview"] as? Bool ?? false

        let ts   = data["date"] as? Timestamp ?? Timestamp(date: Date())
        let date = ts.dateValue()

        var imageData: Data?
        if let b64 = data["image_base64"] as? String, !b64.isEmpty {
            imageData = Data(base64Encoded: b64)
        }

        var proofData: Data?
        if let b64 = data["proof_base64"] as? String, !b64.isEmpty {
            proofData = Data(base64Encoded: b64)
        }

        return ReportModel(
            reportId: reportId,
            title: title,
            category: category,
            location: location,
            description: description,
            imageData: imageData,
            proofImageData: proofData,
            status: status,
            date: date,
            isUrgent: isUrgent,
            submittedByUserId: submittedBy,
            assignedTechnicianId: assignedId,
            assignedTechnicianName: assignedName,
            needsAdminReview: needsAdminReview
        )
    }

    func addReport(
        title: String,
        category: String,
        location: String,
        description: String,
        image: UIImage?,
        isUrgent: Bool,
        submittedByUserId: String,
        completion: @escaping (Bool) -> Void
    ) {
        isLoading = true

        var imageString = ""
        if let img = image {
            let resized = img.resizedToMaxDimension(800)
            if let data = resized.jpegData(compressionQuality: 0.3) {
                imageString = data.base64EncodedString()
            }
        }

        let newId = "AQ-\(Int.random(in: 1000...9999))"
        let payload: [String: Any] = [
            "reportId":               newId,
            "title":                  title,
            "category":               category,
            "location":               location,
            "description":            description.isEmpty ? "Tidak ada deskripsi" : description,
            "image_base64":           imageString,
            "proof_base64":           "",
            "status":                 "Pending",
            "date":                   Timestamp(date: Date()),
            "isUrgent":               isUrgent,
            "submittedByUserId":      submittedByUserId,
            "assignedTechnicianId":   "",
            "assignedTechnicianName": ""
        ]

        db.collection("reports").document(newId).setData(payload) { error in
            DispatchQueue.main.async {
                self.isLoading = false
                completion(error == nil)
            }
        }
    }

    func assignTechnician(
        reportId: String,
        technicianId: String,
        technicianName: String,
        completion: @escaping (Bool) -> Void
    ) {
        db.collection("reports").document(reportId).updateData([
            "assignedTechnicianId":   technicianId,
            "assignedTechnicianName": technicianName,
            "status":                 "In Progress"
        ]) { error in
            DispatchQueue.main.async {
                completion(error == nil)
            }
        }
    }

    func submitProof(
        reportId: String,
        proofImage: UIImage?,
        completion: @escaping (Bool) -> Void
    ) {
        var proofBase64 = ""
        if let image = proofImage {
            let resized = image.resizedToMaxDimension(800)
            if let data = resized.jpegData(compressionQuality: 0.3) {
                proofBase64 = data.base64EncodedString()
            }
        }

        db.collection("reports").document(reportId).updateData([
            "proof_base64": proofBase64,
            "status":       "Completed"
        ]) { error in
            DispatchQueue.main.async {
                completion(error == nil)
            }
        }
    }

    func verifyCompletion(
        reportId: String,
        approved: Bool,
        completion: @escaping (Bool) -> Void
    ) {
        let newStatus = approved ? "Completed" : "Pending"
        var updates: [String: Any] = ["status": newStatus]
        if !approved {
            updates["assignedTechnicianId"]   = ""
            updates["assignedTechnicianName"] = ""
            updates["proof_base64"]           = ""
            updates["needsAdminReview"]       = true
        }
        db.collection("reports").document(reportId).updateData(updates) { error in
            DispatchQueue.main.async {
                completion(error == nil)
            }
        }
    }

    func updateReportStatus(reportId: String, newStatus: String) {
        db.collection("reports").document(reportId).updateData(["status": newStatus])
    }

    var pendingReports:     [ReportModel] { reports.filter { $0.status == "Pending" } }
    var needsReviewReports: [ReportModel] { reports.filter { $0.needsAdminReview && $0.status == "Pending" } }
    var inProgressReports:  [ReportModel] { reports.filter { $0.status == "In Progress" } }
    var completedReports:   [ReportModel] { reports.filter { $0.status == "Completed" } }

    func reports(forUser userId: String)       -> [ReportModel] { reports.filter { $0.submittedByUserId == userId } }
    func reports(assignedTo techId: String)    -> [ReportModel] { reports.filter { $0.assignedTechnicianId == techId } }
    func getReportsByStatus(_ status: String)  -> [ReportModel] { reports.filter { $0.status == status } }
}
