//
//  TechnicianDashboardView.swift
//  shannonfinaltestSEfix
//
//  Created by Vincent on 02/06/26.
//
import SwiftUI

struct TechnicianDashboardView: View {
    @EnvironmentObject var authController:   AuthController
    @EnvironmentObject var reportController: ReportController

    private var myReports: [ReportModel] {
        guard let uid = authController.currentUser?.id else { return [] }
        return reportController.reports(assignedTo: uid)
    }

    private var activeReports: [ReportModel] {
        myReports.filter { $0.status == "In Progress" }
    }

    private var doneReports: [ReportModel] {
        myReports.filter { $0.status == "Completed" }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    TechnicianHeader(userName: authController.currentUser?.name ?? "Teknisi")

                    HStack(spacing: 12) {
                        StatCard(title: "Aktif",   value: "\(activeReports.count)", icon: "wrench.fill",          color: .green)
                        StatCard(title: "Selesai", value: "\(doneReports.count)",   icon: "checkmark.circle.fill", color: .gray)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "wrench.fill").foregroundColor(.green)
                            Text("Laporan Aktif").font(.headline).fontWeight(.semibold)
                            Spacer()
                            Text("\(activeReports.count) laporan").font(.caption).foregroundColor(.gray)
                        }

                        if activeReports.isEmpty {
                            EmptyTechCard(message: "Tidak ada laporan aktif yang di-assign ke Anda.")
                        } else {
                            ForEach(activeReports) { report in
                                NavigationLink(destination: TechnicianSubmitProofView(report: report)) {
                                    TechnicianReportCard(report: report)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)

                    if !doneReports.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill").foregroundColor(.gray)
                                Text("Sudah Selesai").font(.headline).fontWeight(.semibold)
                                Spacer()
                            }
                            ForEach(doneReports.prefix(3)) { report in
                                NavigationLink(destination: ReportDetailView(report: report)) {
                                    TechnicianReportCard(report: report)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationTitle("Tugas Teknisi")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
