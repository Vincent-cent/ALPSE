//
//  AdminHomeView.swift
//  shannonfinaltestSEfix
//

import SwiftUI
import Combine

struct AdminHomeView: View {
    @EnvironmentObject var authController:   AuthController
    @EnvironmentObject var reportController: ReportController
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            AdminDashboardView()
                .tabItem { Label("Dashboard", systemImage: "chart.bar.fill") }
                .tag(0)

            CreateEmployeeView()
                .tabItem { Label("Buat Akun", systemImage: "person.badge.plus") }
                .tag(1)

            ProfileView()
                .tabItem { Label("Profil", systemImage: "person.circle.fill") }
                .tag(2)
        }
        .accentColor(.indigo)
        .onAppear { authController.fetchTechnicians() }
    }
}

struct AdminDashboardView: View {
    @EnvironmentObject var authController:   AuthController
    @EnvironmentObject var reportController: ReportController

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    AdminHeader(userName: authController.currentUser?.name ?? "Admin")

                    AdminStatsRow(reportController: reportController)

                    AdminPendingSection()

                    AdminNeedsReviewSection()

                    AdminInProgressSection()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationTitle("Dashboard Admin")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct AdminHeader: View {
    let userName: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Selamat datang,").font(.subheadline).foregroundColor(.gray)
                Text(userName).font(.title2).fontWeight(.bold)
                Text("Panel Admin AquaAlert").font(.caption).foregroundColor(.indigo)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 55, height: 55)
                Image(systemName: "shield.fill").font(.title2).foregroundColor(.white)
            }
        }
        .padding(.top, 16)
    }
}

struct AdminStatsRow: View {
    @ObservedObject var reportController: ReportController

    var body: some View {
        HStack(spacing: 12) {
            AdminStatCard(title: "Total",      value: reportController.reports.count,        color: .blue,   icon: "doc.text.fill")
            AdminStatCard(title: "Pending",    value: reportController.pendingReports.count,  color: .orange, icon: "clock.fill")
            AdminStatCard(title: "Dikerjakan", value: reportController.inProgressReports.count, color: .green, icon: "arrow.triangle.2.circlepath")
            AdminStatCard(title: "Selesai",    value: reportController.completedReports.count, color: .gray,  icon: "checkmark.circle.fill")
        }
    }
}

struct AdminStatCard: View {
    let title: String
    let value: Int
    let color: Color
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle().fill(color.opacity(0.15)).frame(width: 38, height: 38)
                Image(systemName: icon).font(.callout).foregroundColor(color)
            }
            Text("\(value)").font(.title3).fontWeight(.bold)
            Text(title).font(.caption2).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 4)
    }
}

struct AdminPendingSection: View {
    @EnvironmentObject var reportController: ReportController

    var pendingUnassigned: [ReportModel] {
        reportController.pendingReports.filter { $0.assignedTechnicianId.isEmpty }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.badge.exclamationmark").foregroundColor(.orange)
                Text("Perlu Di-Assign").font(.headline).fontWeight(.semibold)
                Spacer()
                Text("\(pendingUnassigned.count) laporan").font(.caption).foregroundColor(.gray)
            }

            if pendingUnassigned.isEmpty {
                EmptyAdminCard(message: "Semua laporan sudah di-assign.")
            } else {
                ForEach(pendingUnassigned) { report in
                    NavigationLink(destination: AssignTechnicianView(report: report)) {
                        AdminReportCard(report: report, showAssignButton: true)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

struct AdminNeedsReviewSection: View {
    @EnvironmentObject var reportController: ReportController

    var body: some View {
        if !reportController.needsReviewReports.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.red)
                    Text("Dikembalikan Ketua RT/RW").font(.headline).fontWeight(.semibold)
                    Spacer()
                    Text("\(reportController.needsReviewReports.count)").font(.caption).foregroundColor(.red)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Color.red.opacity(0.15))
                        .cornerRadius(8)
                }

                Text("Laporan berikut ditolak oleh Ketua RT/RW dan perlu di-assign ulang ke teknisi lain.")
                    .font(.caption)
                    .foregroundColor(.gray)

                ForEach(reportController.needsReviewReports) { report in
                    NavigationLink(destination: AssignTechnicianView(report: report)) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "arrow.uturn.backward.circle.fill").foregroundColor(.red).font(.caption)
                                Text("Dikembalikan oleh Ketua RT/RW").font(.caption2).foregroundColor(.red).fontWeight(.medium)
                                Spacer()
                                Text(report.reportId).font(.caption2).foregroundColor(.gray)
                            }
                            Text(report.title).font(.subheadline).fontWeight(.semibold)
                            HStack(spacing: 6) {
                                Image(systemName: "location.fill").font(.caption2).foregroundColor(.gray)
                                Text(report.location).font(.caption).foregroundColor(.gray).lineLimit(1)
                            }
                            HStack {
                                Spacer()
                                Text("Tap untuk assign ulang →").font(.caption).foregroundColor(.red).fontWeight(.medium)
                            }
                        }
                        .padding()
                        .background(Color.red.opacity(0.06))
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.3), lineWidth: 1))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
        }
    }
}

struct AdminInProgressSection: View {
    @EnvironmentObject var reportController: ReportController

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "arrow.triangle.2.circlepath").foregroundColor(.green)
                Text("Sedang Dikerjakan").font(.headline).fontWeight(.semibold)
                Spacer()
                Text("\(reportController.inProgressReports.count) laporan").font(.caption).foregroundColor(.gray)
            }

            if reportController.inProgressReports.isEmpty {
                EmptyAdminCard(message: "Tidak ada laporan yang sedang dikerjakan.")
            } else {
                ForEach(reportController.inProgressReports.prefix(5)) { report in
                    NavigationLink(destination: ReportDetailView(report: report)) {
                        AdminReportCard(report: report, showAssignButton: false)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}
#Preview {
    AdminHomeView()
        .environmentObject(AuthController())
        .environmentObject(ReportController())
}
