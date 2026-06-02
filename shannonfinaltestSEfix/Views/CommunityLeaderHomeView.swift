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

struct VerifyReportView: View {
    let report: ReportModel

    @EnvironmentObject var reportController: ReportController
    @Environment(\.dismiss) var dismiss

    @State private var showApproveAlert  = false
    @State private var showRejectAlert   = false
    @State private var showSuccessAlert  = false
    @State private var successMessage    = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Informasi Laporan").font(.headline)
                    CLReportCard(report: report)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Deskripsi Masalah").font(.subheadline).fontWeight(.semibold)
                        Text(report.description).font(.body).foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }

                Divider()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Foto Bukti dari Teknisi").font(.headline)
                    if let proofImg = report.proofImage {
                        Image(uiImage: proofImg)
                            .resizable().scaledToFit()
                            .cornerRadius(12)
                    } else {
                        HStack {
                            Image(systemName: "photo.slash").foregroundColor(.gray)
                            Text("Belum ada foto bukti yang dikirim teknisi.")
                                .font(.caption).foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }

                Divider()

                VStack(spacing: 14) {
                    Text("Verifikasi Hasil Pekerjaan").font(.headline)
                    Text("Pilih tindakan berdasarkan hasil verifikasi di lapangan:")
                        .font(.caption).foregroundColor(.gray)

                    Button(action: { showApproveAlert = true }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Setujui — Pekerjaan Selesai").fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }

                    Button(action: { showRejectAlert = true }) {
                        HStack {
                            Image(systemName: "arrow.uturn.backward.circle.fill")
                            Text("Tolak — Kembalikan ke Admin").fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Verifikasi Laporan")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Setujui Pekerjaan?", isPresented: $showApproveAlert) {
            Button("Batal", role: .cancel) { }
            Button("Ya, Setujui") { verify(approved: true) }
        } message: {
            Text("Konfirmasi bahwa pekerjaan pada laporan \(report.reportId) sudah selesai dengan baik.")
        }
        .alert("Tolak & Kembalikan?", isPresented: $showRejectAlert) {
            Button("Batal", role: .cancel) { }
            Button("Ya, Tolak", role: .destructive) { verify(approved: false) }
        } message: {
            Text("Laporan akan dikembalikan ke status Pending dan admin akan diberitahu untuk menugaskan ulang.")
        }
        .alert("Berhasil!", isPresented: $showSuccessAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text(successMessage)
        }
    }

    private func verify(approved: Bool) {
        reportController.verifyCompletion(reportId: report.reportId, approved: approved) { success in
            if success {
                successMessage = approved
                    ? "Laporan \(report.reportId) telah diverifikasi sebagai selesai."
                    : "Laporan \(report.reportId) dikembalikan ke Pending. Admin akan mendapat notifikasi untuk assign ulang."
                showSuccessAlert = true
            }
        }
    }
}

struct AllReportsView: View {
    @EnvironmentObject var reportController: ReportController
    @State private var selectedFilter = "Semua"

    let filters = ["Semua", "Pending", "In Progress", "Completed"]

    private var filteredReports: [ReportModel] {
        if selectedFilter == "Semua" { return reportController.reports }
        return reportController.reports.filter { $0.status == selectedFilter }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(filters, id: \.self) { f in
                            FilterChip(title: f, isSelected: selectedFilter == f) {
                                withAnimation { selectedFilter = f }
                            }
                        }
                    }
                    .padding(.horizontal).padding(.vertical, 10)
                }

                if filteredReports.isEmpty {
                    Spacer()
                    Text("Tidak ada laporan.").foregroundColor(.gray)
                    Spacer()
                } else {
                    List {
                        ForEach(filteredReports) { report in
                            NavigationLink(destination: ReportDetailView(report: report)) {
                                ReportCard(report: report)
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Semua Laporan")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGray6).ignoresSafeArea())
        }
    }
}

#Preview {
    CommunityLeaderHomeView()
        .environmentObject(AuthController())
        .environmentObject(ReportController())
}
