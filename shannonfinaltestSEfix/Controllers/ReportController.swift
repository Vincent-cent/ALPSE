//
//  ReportController.swift
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import Combine
import UIKit

extension UIImage {
    func resizedToMaxDimension(_ maxDimension: CGFloat) -> UIImage {
        let aspectRatio = size.width / size.height
        let newWidth = min(size.width, maxDimension)
        let newHeight = newWidth / aspectRatio
        
        let newSize = CGSize(width: newWidth, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

class ReportController: ObservableObject {
    @Published var reports: [ReportModel] = []
    @Published var isLoading = false
    
    private lazy var db = Firestore.firestore()
    private lazy var storage = Storage.storage()
    
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
        let imageUrl = (data["image_url"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let proofUrl = (data["proof_url"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
        
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
            status: status,
            date: date,
            isUrgent: isUrgent,
            submittedByUserId: submittedBy,
            assignedTechnicianId: assignedId,
            assignedTechnicianName: assignedName,
            needsAdminReview: needsAdminReview
        )
    }
    
    private func makeJpegData(_ image: UIImage?, maxDimension: CGFloat = 640, compressionQuality: CGFloat = 0.25) -> Data? {
        guard let image = image else { return nil }
        let resized = image.resizedToMaxDimension(maxDimension)
        return resized.jpegData(compressionQuality: compressionQuality)
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
            let imageData = self.makeJpegData(image)
            let newId = "AQ-\(Int.random(in: 1000...9999))"
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
            
            guard let imageData = imageData else {
                payload["image_url"] = ""
                self.db.collection("reports").document(newId).setData(payload) { error in
                    DispatchQueue.main.async {
                        self.isLoading = false
                        completion(error == nil)
                    }
                }
                return
            }
            
            let imageRef = self.storage.reference().child("reports/\(newId)/report.jpg")
            imageRef.putData(imageData, metadata: nil) { [weak self] _, error in
                guard let self = self else { return }
                guard error == nil else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        completion(false)
                    }
                    return
                }
                imageRef.downloadURL { url, urlError in
                    guard urlError == nil else {
                        DispatchQueue.main.async {
                            self.isLoading = false
                            completion(false)
                        }
                        return
                    }
                    payload["image_url"] = url?.absoluteString ?? ""
                    self.db.collection("reports").document(newId).setData(payload) { err in
                        DispatchQueue.main.async {
                            self.isLoading = false
                            completion(err == nil)
                        }
                    }
                }
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
            guard let proofData = self.makeJpegData(proofImage) else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    completion(false)
                }
                return
            }
            
            let proofRef = self.storage.reference().child("reports/\(reportId)/proof.jpg")
            imageRef.putData(imageData, metadata: metadata) { [weak self] _, error in
                if let error = error {
                    print("❌ Upload Error: \(error.localizedDescription)")
                }
                guard error == nil else {
                    DispatchQueue.main.async {
                        self.isLoading = false
                        completion(false)
                    }
                    return
                }
                proofRef.downloadURL { url, urlError in
                    guard urlError == nil else {
                        DispatchQueue.main.async {
                            self.isLoading = false
                            completion(false)
                        }
                        return
                    }
                    self.db.collection("reports").document(reportId).updateData([
                        "status":       "Completed",
                        "proof_base64": "",
                        "proof_url":    url?.absoluteString ?? ""
                    ]) { err in
                        DispatchQueue.main.async {
                            self.isLoading = false
                            completion(err == nil)
                        }
                    }
                }
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
