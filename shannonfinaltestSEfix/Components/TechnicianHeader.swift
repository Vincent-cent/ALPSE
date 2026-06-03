//
//  TechnicianHeader.swift
//  shannonfinaltestSEfix
//
//  Created by Vincent on 02/06/26.
//
import SwiftUI

struct TechnicianHeader: View {
    let userName: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Halo, Teknisi 👋").font(.subheadline).foregroundColor(.gray)
                Text(userName).font(.title2).fontWeight(.bold)
                Text("Kerjakan laporan yang telah di-assign ke Anda").font(.caption).foregroundColor(.green)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.green, .teal], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 55, height: 55)
                Image(systemName: "wrench.fill").font(.title2).foregroundColor(.white)
            }
        }
        .padding(.top, 16)
    }
}

struct TechnicianReportCard: View {
    let report: ReportModel

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
            if report.status == "In Progress" {
                HStack {
                    Spacer()
                    Text("Tap untuk upload bukti & selesaikan →")
                        .font(.caption).foregroundColor(.green).fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
