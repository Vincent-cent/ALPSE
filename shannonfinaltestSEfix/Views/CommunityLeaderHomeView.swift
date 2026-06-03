//
//  CommunityLeaderHomeView.swift
//  shannonfinaltestSEfix

import SwiftUI

struct CommunityLeaderHomeView: View {
    @EnvironmentObject var authController:   AuthController
    @EnvironmentObject var reportController: ReportController
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            CommunityLeaderDashboardView()
                .tabItem { Label("Verifikasi", systemImage: "checkmark.seal.fill") }
                .tag(0)

            AllReportsView()
                .tabItem { Label("Semua Laporan", systemImage: "list.bullet.rectangle") }
                .tag(1)

            ProfileView()
                .tabItem { Label("Profil", systemImage: "person.circle.fill") }
                .tag(2)
        }
        .accentColor(.purple)
    }
}

struct CommunityLeaderDashboardView: View {
    @EnvironmentObject var reportController: ReportController
    @EnvironmentObject var authController:   AuthController

    private var needsVerification: [ReportModel] {
        reportController.completedReports
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    CLHeader(userName: authController.currentUser?.name ?? "Ketua RT/RW")

                    HStack(spacing: 12) {
                        StatCard(title: "Perlu Verifikasi", value: "\(needsVerification.count)", icon: "checkmark.seal", color: .purple)
                        StatCard(title: "Total Laporan",    value: "\(reportController.reports.count)", icon: "doc.text.fill", color: .blue)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.seal.fill").foregroundColor(.purple)
                            Text("Perlu Diverifikasi").font(.headline).fontWeight(.semibold)
                            Spacer()
                            Text("\(needsVerification.count) laporan").font(.caption).foregroundColor(.gray)
                        }

                        if needsVerification.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill").font(.system(size: 40)).foregroundColor(.green)
                                Text("Tidak ada laporan yang perlu diverifikasi saat ini.")
                                    .font(.caption).foregroundColor(.gray).multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        } else {
                            ForEach(needsVerification) { report in
                                NavigationLink(destination: VerifyReportView(report: report)) {
                                    CLReportCard(report: report)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationTitle("Panel Ketua RT/RW")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct CLHeader: View {
    let userName: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Halo, Ketua RT/RW 👋").font(.subheadline).foregroundColor(.gray)
                Text(userName).font(.title2).fontWeight(.bold)
                Text("Verifikasi laporan yang sudah dikerjakan").font(.caption).foregroundColor(.purple)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 55, height: 55)
                Image(systemName: "person.3.fill").font(.title3).foregroundColor(.white)
            }
        }
        .padding(.top, 16)
    }
}

struct CLReportCard: View {
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
            if !report.assignedTechnicianName.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "wrench.fill").font(.caption2).foregroundColor(.green)
                    Text("Teknisi: \(report.assignedTechnicianName)").font(.caption).foregroundColor(.green)
                }
            }
            HStack {
                Spacer()
                Text("Tap untuk verifikasi →").font(.caption).foregroundColor(.purple).fontWeight(.medium)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}




#Preview {
    CommunityLeaderHomeView()
        .environmentObject(AuthController())
        .environmentObject(ReportController())
}
