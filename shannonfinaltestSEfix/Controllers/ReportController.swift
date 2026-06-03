//
//  ReportController.swift
//

import Foundation
import SwiftUI
import FirebaseFirestore
import Combine
import UIKit

class ReportController: ObservableObject {
    @Published var reports: [ReportModel] = []
    @Published var isLoading = false
    
    private lazy var db = Firestore.firestore()
    
    init(shouldListen: Bool = true) {
        if shouldListen {
            listenToAllReports()
        }
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
    
    func parseReport(from data: [String: Any]) -> ReportModel? {
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
        let imageUrl = nonEmptyString(data["image_url"])
        let proofUrl = nonEmptyString(data["proof_url"])
        
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
            needsAdminReview: needsAdminReview,
            imageUrl: imageUrl,
            proofImageUrl: proofUrl
        )
    }
    
    private func nonEmptyString(_ value: Any?) -> String? {
        guard let string = value as? String else { return nil }
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
    
    private func makeJpegData(_ image: UIImage?, maxDimension: CGFloat = 640, compressionQuality: CGFloat = 0.25) -> Data? {
        guard let image = image else { return nil }
        let resized = image.resizedToMaxDimension(maxDimension)
        return resized.jpegData(compressionQuality: compressionQuality)
    }
    
    private func finishLoading(_ success: Bool, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            self.isLoading = false
            completion(success)
        }
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
        
        DispatchQueue.global(qos: .userInitiated).async {
            let imageData = self.makeJpegData(image, maxDimension: 480, compressionQuality: 0.2)
            let newId = "AQ-\(UUID().uuidString.prefix(8).uppercased())"
            var payload: [String: Any] = [
                "reportId":               newId,
                "title":                  title,
                "category":               category,
                "location":               location,
                "description":            description.isEmpty ? "Tidak ada deskripsi" : description,
                "image_base64":           "",
                "proof_base64":           "",
                "status":                 "Pending",
                "date":                   Timestamp(date: Date()),
                "isUrgent":               isUrgent,
                "submittedByUserId":      submittedByUserId,
                "assignedTechnicianId":   "",
                "assignedTechnicianName": ""
            ]
            
            if let imageData = imageData {
                payload["image_base64"] = imageData.base64EncodedString()
            }
            payload["image_url"] = ""
            
            self.db.collection("reports").document(newId).setData(payload) { error in
                self.finishLoading(error == nil, completion: completion)
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
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            guard let proofData = self.makeJpegData(proofImage, maxDimension: 480, compressionQuality: 0.2) else {
                self.finishLoading(false, completion: completion)
                return
            }
            
            self.db.collection("reports").document(reportId).updateData([
                "status":       "Completed",
                "proof_base64": proofData.base64EncodedString(),
                "proof_url":    ""
            ]) { error in
                self.finishLoading(error == nil, completion: completion)
            }
        }
    }
    
    func fetchProof(reportId: String, completion: @escaping (Data?) -> Void) {
        db.collection("reports").document(reportId)
            .collection("proof").document(reportId)
            .getDocument { snapshot, _ in
                guard
                    let b64 = snapshot?.data()?["proof_base64"] as? String,
                    !b64.isEmpty,
                    let data = Data(base64Encoded: b64)
                else {
                    completion(nil)
                    return
                }
                completion(data)
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
            updates["proof_url"]              = ""
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
