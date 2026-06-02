//
//  ReportModel.swift
//  shannonfinaltestSEfix
//

import Foundation
import SwiftUI

// MARK: - Report Model
struct ReportModel: Identifiable {
    let id = UUID()
    let reportId: String
    let title: String
    let category: String
    let location: String
    let description: String
    let imageData: Data?
    let proofImageData: Data?        // foto bukti dari teknisi
    let status: String
    let date: Date
    let isUrgent: Bool
    let submittedByUserId: String    // user yang submit laporan
    let assignedTechnicianId: String // teknisi yang di-assign
    let assignedTechnicianName: String
    let needsAdminReview: Bool      // true jika Community Leader menolak & mengembalikan ke admin

    var image: UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }

    var proofImage: UIImage? {
        guard let proofImageData = proofImageData else { return nil }
        return UIImage(data: proofImageData)
    }

    var statusColor: Color {
        switch status {
        case "Pending":     return .orange
        case "Verified":    return .blue
        case "In Progress": return .green
        case "Completed":   return Color(red: 0.2, green: 0.6, blue: 0.2)
        case "Rejected":    return .red
        default:            return .gray
        }
    }

    var statusDisplayName: String {
        switch status {
        case "Pending":     return "Menunggu"
        case "Verified":    return "Diverifikasi"
        case "In Progress": return "Sedang Dikerjakan"
        case "Completed":   return "Selesai"
        case "Rejected":    return "Ditolak"
        default:            return status
        }
    }

    static let sampleReports: [ReportModel] = [
        ReportModel(
            reportId: "AQ-001",
            title: "Pipa PDAM Bocor",
            category: "Pipa Bocor",
            location: "Jl. Mawar No.5, RT02/RW03",
            description: "Air mengalir deras sejak 2 hari.",
            imageData: nil,
            proofImageData: nil,
            status: "Pending",
            date: Date().addingTimeInterval(-86400 * 3),
            isUrgent: true,
            submittedByUserId: "user1",
            assignedTechnicianId: "",
            assignedTechnicianName: "",
            needsAdminReview: false
        ),
        ReportModel(
            reportId: "AQ-002",
            title: "Saluran Drainase Mampet",
            category: "Saluran Mampet",
            location: "Gg. Melati, belakang masjid",
            description: "Air tidak mengalir, bau tidak sedap.",
            imageData: nil,
            proofImageData: nil,
            status: "In Progress",
            date: Date().addingTimeInterval(-86400 * 2),
            isUrgent: false,
            submittedByUserId: "user1",
            assignedTechnicianId: "tech1",
            assignedTechnicianName: "Budi",
            needsAdminReview: false
        )
    ]
}

// MARK: - User Model
struct UserModel {
    let id: String
    let name: String
    let email: String
    let role: String
    let avatarColor: Color

    var roleDisplayName: String {
        switch role {
        case "resident":         return "Warga"
        case "community_leader": return "Ketua RT/RW"
        case "admin":            return "Admin"
        case "technician":       return "Teknisi"
        default:                 return "Warga"
        }
    }

    init(id: String, name: String, email: String, role: String, avatarColor: Color? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.avatarColor = avatarColor ?? {
            let colors: [Color] = [.blue, .green, .orange, .purple, .pink]
            return colors[abs(name.hashValue) % colors.count]
        }()
    }
}

// MARK: - Category Model
struct ReportCategory {
    let name: String
    let icon: String
    let color: Color

    static let allCategories = [
        ReportCategory(name: "Pipa Bocor",      icon: "drop.fill",                      color: .blue),
        ReportCategory(name: "Saluran Mampet",  icon: "flowchart.fill",                 color: .orange),
        ReportCategory(name: "Kualitas Air",    icon: "eyedropper.full",                color: .green),
        ReportCategory(name: "Fasilitas Rusak", icon: "wrench.fill",                    color: .red),
        ReportCategory(name: "Lainnya",         icon: "exclamationmark.triangle.fill",  color: .gray)
    ]
}
