//
//  AdminReportCard.swift
//  shannonfinaltestSEfix
//
//  Created by Vincent on 02/06/26.
//
import SwiftUI

struct AdminReportCard: View {
    let report: ReportModel
    let showAssignButton: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                StatusBadge(status: report.status)
                if report.isUrgent {
                    Label("Darurat", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption2).foregroundColor(.red)
                }
                Spacer()
                Text(report.reportId).font(.caption2).foregroundColor(.gray)
            }
            Text(report.title).font(.subheadline).fontWeight(.semibold)
            HStack(spacing: 6) {
                Image(systemName: "location.fill").font(.caption2).foregroundColor(.gray)
                Text(report.location).font(.caption).foregroundColor(.gray).lineLimit(1)
            }
            if !report.assignedTechnicianName.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "wrench.fill").font(.caption2).foregroundColor(.green)
                    Text("Teknisi: \(report.assignedTechnicianName)").font(.caption).foregroundColor(.green)
                }
            }
            if showAssignButton {
                HStack {
                    Spacer()
                    Text("Tap untuk assign teknisi →")
                        .font(.caption).foregroundColor(.indigo).fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
