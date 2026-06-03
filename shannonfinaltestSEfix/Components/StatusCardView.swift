//
//  StatusCardView.swift
//  shannonfinaltestSEfix
//
//  Created by Vincent on 02/06/26.
//
import SwiftUI

struct StatusCardView: View {
    let report: ReportModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                StatusBadge(status: report.status)
                Spacer()
                Text(report.reportId)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            Text(report.title)
                .font(.headline)
                .fontWeight(.semibold)
            HStack(spacing: 8) {
                Image(systemName: "location.fill")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text(report.location)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            if !report.assignedTechnicianName.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "wrench.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                    Text("Teknisi: \(report.assignedTechnicianName)")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            if report.isUrgent {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundColor(.red)
                    Text("Prioritas Darurat")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}
