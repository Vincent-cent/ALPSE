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

struct EmptyAdminCard: View {
    let message: String

    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
            Text(message).font(.caption).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct AssignTechnicianView: View {
    let report: ReportModel

    @EnvironmentObject var authController:   AuthController
    @EnvironmentObject var reportController: ReportController
    @Environment(\.dismiss) var dismiss

    @State private var selectedTechnicianId   = ""
    @State private var selectedTechnicianName = ""
    @State private var showSuccess = false
    @State private var showError   = false
    @State private var errorMsg    = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Detail Laporan").font(.headline)
                    AdminReportCard(report: report, showAssignButton: false)
                }

                Divider()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Pilih Teknisi").font(.headline)

                    if authController.technicians.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "person.slash").font(.largeTitle).foregroundColor(.gray)
                            Text("Belum ada teknisi terdaftar.\nBuat akun teknisi di tab \"Buat Akun\" terlebih dahulu.")
                                .font(.caption).foregroundColor(.gray).multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Pilih nama teknisi yang tersedia:")
                                .font(.caption).foregroundColor(.gray)

                            Menu {
                                ForEach(authController.technicians) { tech in
                                    Button(action: {
                                        selectedTechnicianId   = tech.id
                                        selectedTechnicianName = tech.name
                                    }) {
                                        HStack {
                                            Text(tech.name)
                                            Spacer()
                                            Text(tech.email).foregroundColor(.gray)
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "person.fill").foregroundColor(.indigo)
                                    Text(selectedTechnicianName.isEmpty ? "Pilih Teknisi..." : selectedTechnicianName)
                                        .foregroundColor(selectedTechnicianName.isEmpty ? .gray : .primary)
                                        .fontWeight(selectedTechnicianName.isEmpty ? .regular : .semibold)
                                    Spacer()
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedTechnicianName.isEmpty ? Color.gray.opacity(0.3) : Color.indigo, lineWidth: 1.5)
                                )
                            }

                            if !selectedTechnicianId.isEmpty,
                               let selectedTech = authController.technicians.first(where: { $0.id == selectedTechnicianId }) {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle().fill(Color.indigo).frame(width: 40, height: 40)
                                        Text(String(selectedTech.name.prefix(1)).uppercased())
                                            .font(.headline).fontWeight(.bold).foregroundColor(.white)
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(selectedTech.name).font(.subheadline).fontWeight(.semibold)
                                        Text(selectedTech.email).font(.caption).foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "checkmark.circle.fill").foregroundColor(.indigo)
                                }
                                .padding()
                                .background(Color.indigo.opacity(0.08))
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.indigo, lineWidth: 1))
                            }
                        }
                    }
                }

                Button(action: assignTechnician) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Simpan & Assign Teknisi").fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(selectedTechnicianId.isEmpty ? Color.gray : Color.indigo)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(selectedTechnicianId.isEmpty)
            }
            .padding()
        }
        .navigationTitle("Assign Teknisi")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { authController.fetchTechnicians() }
        .alert("Berhasil!", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Laporan \(report.reportId) telah di-assign ke \(selectedTechnicianName). Status laporan berubah menjadi \"Sedang Dikerjakan\".")
        }
        .alert("Gagal", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMsg)
        }
    }

    private func assignTechnician() {
        reportController.assignTechnician(
            reportId: report.reportId,
            technicianId: selectedTechnicianId,
            technicianName: selectedTechnicianName
        ) { success in
            if success { showSuccess = true }
            else { errorMsg = "Gagal menyimpan. Coba lagi."; showError = true }
        }
    }
}

struct CreateEmployeeView: View {
    var body: some View {
        NavigationView {
            CreateEmployeeContent()
        }
    }
}

struct CreateEmployeeContent: View {
    @EnvironmentObject var authController: AuthController

    @State private var name            = ""
    @State private var email           = ""
    @State private var password        = ""
    @State private var confirmPassword = ""
    @State private var selectedRole    = "technician"
    @State private var showAlert       = false
    @State private var alertTitle      = ""
    @State private var alertMessage    = ""
    @State private var isSuccess       = false

    let roles: [(String, String, String)] = [
        ("technician",       "Teknisi",      "wrench.fill"),
        ("community_leader", "Ketua RT/RW",  "person.3.fill"),
        ("admin",            "Admin",         "shield.fill")
    ]

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 10) {
                            ZStack {
                                Circle().fill(Color.indigo.opacity(0.15)).frame(width: 80, height: 80)
                                Image(systemName: "person.badge.key.fill").font(.system(size: 35)).foregroundColor(.indigo)
                            }
                            Text("Buat Akun Pegawai").font(.title2).fontWeight(.bold)
                            Text("Hanya Admin yang dapat membuat akun Teknisi, Ketua RT/RW, dan Admin baru.")
                                .font(.caption).foregroundColor(.gray).multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 24)

                        VStack(spacing: 18) {
                            FormField(label: "Nama Lengkap", icon: "person", placeholder: "Nama pegawai", text: $name)
                            FormField(label: "Email", icon: "envelope", placeholder: "email@example.com", text: $email, isEmail: true)
                            FormField(label: "Password", icon: "lock", placeholder: "Minimal 6 karakter", text: $password, isSecure: true)
                            FormField(label: "Konfirmasi Password", icon: "lock.shield", placeholder: "Ulang password", text: $confirmPassword, isSecure: true)
                        }
                        .padding(.horizontal, 24)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Pilih Role Pegawai")
                                .font(.caption).fontWeight(.medium).foregroundColor(.gray)
                                .padding(.horizontal, 24)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(roles, id: \.0) { role in
                                        EmployeeRoleCard(
                                            roleName: role.1,
                                            roleIcon: role.2,
                                            isSelected: selectedRole == role.0
                                        ) { selectedRole = role.0 }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }

                        Button(action: createAccount) {
                            HStack {
                                if authController.isLoading {
                                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "person.badge.plus")
                                    Text("Buat Akun Pegawai").fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(authController.isLoading ? Color.gray : Color.indigo)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(authController.isLoading)
                        .padding(.horizontal, 24)

                        Spacer(minLength: 30)
                    }
                }
            }
        .navigationTitle("Buat Akun Pegawai")
        .navigationBarTitleDisplayMode(.inline)
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK") { if isSuccess { clearForm() } }
        } message: {
            Text(alertMessage)
        }
    }

    private func createAccount() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            show(title: "Error", msg: "Nama tidak boleh kosong."); return
        }
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            show(title: "Error", msg: "Email tidak boleh kosong."); return
        }
        guard password.count >= 6 else {
            show(title: "Error", msg: "Password minimal 6 karakter."); return
        }
        guard password == confirmPassword else {
            show(title: "Error", msg: "Konfirmasi password tidak cocok."); return
        }

        authController.createEmployeeAccount(
            username: name,
            email: email,
            password: password,
            role: selectedRole
        ) { success, message in
            isSuccess = success
            alertTitle   = success ? "Berhasil!" : "Gagal"
            alertMessage = message
            showAlert    = true
            if success { authController.fetchTechnicians() }
        }
    }

    private func clearForm() {
        name = ""; email = ""; password = ""; confirmPassword = ""
        selectedRole = "technician"
    }

    private func show(title: String, msg: String) {
        isSuccess = false; alertTitle = title; alertMessage = msg; showAlert = true
    }
}

struct FormField: View {
    let label: String
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isEmail: Bool  = false
    var isSecure: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.caption).fontWeight(.medium).foregroundColor(.gray)
            HStack {
                Image(systemName: icon).foregroundColor(.gray).frame(width: 24)
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .autocapitalization(isEmail ? .none : .words)
                        .keyboardType(isEmail ? .emailAddress : .default)
                }
            }
            .padding(.vertical, 12).padding(.horizontal, 4)
            .background(Rectangle().fill(Color(.systemGray5)).frame(height: 1), alignment: .bottom)
        }
    }
}

struct EmployeeRoleCard: View {
    let roleName: String
    let roleIcon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.indigo : Color(.systemGray5))
                        .frame(width: 55, height: 55)
                    Image(systemName: roleIcon)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? .white : .gray)
                }
                Text(roleName)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .indigo : .gray)
            }
            .frame(width: 90)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.indigo.opacity(0.08) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.indigo : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AdminHomeView()
        .environmentObject(AuthController())
        .environmentObject(ReportController())
}
