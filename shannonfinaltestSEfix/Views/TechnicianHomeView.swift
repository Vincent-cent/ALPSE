//
//  TechnicianHomeView.swift
//

import SwiftUI

struct TechnicianHomeView: View {
    @EnvironmentObject var authController:   AuthController
    @EnvironmentObject var reportController: ReportController
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            TechnicianDashboardView()
                .tabItem { Label("Tugas Saya", systemImage: "wrench.and.screwdriver.fill") }
                .tag(0)

            ProfileView()
                .tabItem { Label("Profil", systemImage: "person.circle.fill") }
                .tag(1)
        }
        .accentColor(.green)
    }
}

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

struct EmptyTechCard: View {
    let message: String

    var body: some View {
        HStack {
            Image(systemName: "checkmark.seal.fill").foregroundColor(.green)
            Text(message).font(.caption).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct TechnicianSubmitProofView: View {
    let report: ReportModel

    @EnvironmentObject var reportController: ReportController
    @Environment(\.dismiss) var dismiss

    @State private var proofImage:     UIImage?
    @State private var showImagePicker = false
    @State private var showSuccess     = false
    @State private var showError       = false
    @State private var errorMsg        = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Detail Laporan").font(.headline)
                    TechnicianReportCard(report: report)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Deskripsi Masalah").font(.subheadline).fontWeight(.semibold)
                        Text(report.description).font(.body).foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    if let img = report.image {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Foto Laporan dari Warga").font(.subheadline).fontWeight(.semibold)
                            Image(uiImage: img)
                                .resizable().scaledToFit()
                                .cornerRadius(10)
                        }
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Upload Foto Bukti Pengerjaan").font(.headline)
                    Text("Ambil atau pilih foto setelah pekerjaan selesai sebagai bukti.")
                        .font(.caption).foregroundColor(.gray)

                    Button(action: { showImagePicker = true }) {
                        if let img = proofImage {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: img)
                                    .resizable().scaledToFit()
                                    .frame(height: 200)
                                    .cornerRadius(12)
                                Button(action: { proofImage = nil }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2).foregroundColor(.white)
                                        .background(Circle().fill(Color.black.opacity(0.6)))
                                }
                                .padding(8)
                            }
                        } else {
                            HStack {
                                Image(systemName: "camera.fill").font(.title2).foregroundColor(.green)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Tambah Foto Bukti").font(.subheadline).fontWeight(.medium)
                                    Text("Pilih dari galeri atau ambil foto").font(.caption2).foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                Button(action: submitProof) {
                    HStack {
                        if reportController.isLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Tandai Selesai & Kirim Bukti").fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(reportController.isLoading ? Color.gray : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(reportController.isLoading)
            }
            .padding()
        }
        .navigationTitle("Submit Bukti")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(image: $proofImage)
        }
        .alert("Berhasil!", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Pekerjaan telah ditandai selesai. Foto bukti telah dikirim. Ketua RT/RW akan memverifikasi hasilnya.")
        }
        .alert("Gagal", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMsg)
        }
    }

    private func submitProof() {
        reportController.submitProof(reportId: report.reportId, proofImage: proofImage) { success in
            if success { showSuccess = true }
            else { errorMsg = "Gagal mengirim bukti. Coba lagi."; showError = true }
        }
    }
}

#Preview {
    TechnicianHomeView()
        .environmentObject(AuthController())
        .environmentObject(ReportController())
}
