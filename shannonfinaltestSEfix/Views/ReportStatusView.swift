//
//  ReportStatusView.swift
//

import SwiftUI

struct ReportStatusView: View {
    @EnvironmentObject var authController:   AuthController
    @EnvironmentObject var reportController: ReportController
    @State private var selectedStatus = "Semua"

    let statusOptions = ["Semua", "Pending", "In Progress", "Completed"]

    private var myReports: [ReportModel] {
        guard let uid = authController.currentUser?.id else { return [] }
        return reportController.reports(forUser: uid)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
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



#Preview {
    ReportStatusView()
        .environmentObject(AuthController())
        .environmentObject(ReportController())
}
