//
//  ReportStatusView.swift
//  shannonfinaltestSEfix
//  Halaman status laporan — dipakai oleh Resident tab
//

import SwiftUI

struct ReportStatusView: View {
    @EnvironmentObject var authController:   AuthController
    @EnvironmentObject var reportController: ReportController
    @State private var selectedStatus = "Semua"

    let statusOptions = ["Semua", "Pending", "In Progress", "Completed"]

    // Hanya tampilkan laporan milik user yang login (resident)
    private var myReports: [ReportModel] {
        guard let uid = authController.currentUser?.id else { return [] }
        return reportController.reports(forUser: uid)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(statusOptions, id: \.self) { s in
                            StatusTab(
                                title: s,
                                isSelected: selectedStatus == s,
                                count: countFor(s)
                            ) { withAnimation { selectedStatus = s } }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .background(Color(.systemBackground))

                ScrollView {
                    VStack(spacing: 20) {
                        let reports = selectedStatus == "Semua"
                            ? myReports
                            : myReports.filter { $0.status == selectedStatus }

                        if reports.isEmpty {
                            VStack(spacing: 20) {
                                Spacer(minLength: 60)
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 45))
                                    .foregroundColor(.gray)
                                Text("Tidak ada laporan dengan status \"\(selectedStatus)\"")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            ForEach(reports) { report in
                                NavigationLink(destination: ReportDetailView(report: report)) {
                                    StatusCardView(report: report)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .background(Color(.systemGray6))
            }
            .navigationTitle("Status Laporan Saya")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private func countFor(_ status: String) -> Int {
        if status == "Semua" { return myReports.count }
        return myReports.filter { $0.status == status }.count
    }
}

// MARK: - StatusTab
struct StatusTab: View {
    let title: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void

    var statusColor: Color {
        switch title {
        case "Pending":     return .orange
        case "In Progress": return .green
        case "Completed":   return Color(red: 0.2, green: 0.6, blue: 0.2)
        case "Rejected":    return .red
        default:            return .blue
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundColor(isSelected ? statusColor : .gray)
                Text("\(count)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(isSelected ? statusColor.opacity(0.15) : Color(.systemGray5))
                    .foregroundColor(isSelected ? statusColor : .gray)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(isSelected ? statusColor.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - StatusCardView
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

#Preview {
    ReportStatusView()
        .environmentObject(AuthController())
        .environmentObject(ReportController())
}
