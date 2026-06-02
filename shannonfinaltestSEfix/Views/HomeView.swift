//
//  HomeView.swift
//  shannonfinaltestSEfix
//  Halaman utama untuk role: Resident (Warga)
//

import SwiftUI

// MARK: - HomeView (Resident)
struct HomeView: View {
    @EnvironmentObject var authController:   AuthController
    @EnvironmentObject var reportController: ReportController
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeMainView()
                .tabItem { Label("Beranda", systemImage: "house.fill") }
                .tag(0)

            ResidentReportHistoryView()
                .tabItem { Label("Laporan Saya", systemImage: "list.bullet.rectangle") }
                .tag(1)

            ReportStatusView()
                .tabItem { Label("Status", systemImage: "chart.line.text.clipboard") }
                .tag(2)

            ProfileView()
                .tabItem { Label("Profil", systemImage: "person.circle.fill") }
                .tag(3)
        }
        .accentColor(.blue)
        .onReceive(NotificationCenter.default.publisher(for: .switchToLaporanTab)) { _ in
            selectedTab = 1
        }
    }
}

// MARK: - HomeMainView
struct HomeMainView: View {
    @EnvironmentObject var authController:   AuthController
    @EnvironmentObject var reportController: ReportController
    @State private var showReportForm = false

    private var myReports: [ReportModel] {
        guard let uid = authController.currentUser?.id else { return [] }
        return reportController.reports(forUser: uid)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    WelcomeHeader(userName: authController.currentUser?.name ?? "Pengguna")

                    // Stats (hanya laporan milik user ini)
                    ResidentStatsRow(
                        total:      myReports.count,
                        inProgress: myReports.filter { $0.status == "In Progress" }.count,
                        completed:  myReports.filter { $0.status == "Completed" }.count
                    )

                    // Quick action
                    Button(action: { showReportForm = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("Buat Laporan Baru")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                    }

                    // Recent reports
                    RecentReportsSection(reports: Array(myReports.prefix(3)))

                    InfoCard()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showReportForm) {
            ReportFormView()
                .environmentObject(reportController)
                .environmentObject(authController)
        }
    }
}

// MARK: - WelcomeHeader
struct WelcomeHeader: View {
    let userName: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Halo, 👋")
                    .font(.title2)
                    .foregroundColor(.gray)
                Text(userName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Text("Ada masalah air atau sanitasi? Laporkan sekarang!")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
            Spacer()
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 55, height: 55)
                Text(String(userName.prefix(1)).uppercased())
                    .font(.title2).fontWeight(.semibold).foregroundColor(.white)
            }
        }
        .padding(.top, 20)
    }
}

// MARK: - ResidentStatsRow
struct ResidentStatsRow: View {
    let total: Int
    let inProgress: Int
    let completed: Int

    var body: some View {
        HStack(spacing: 15) {
            StatCard(title: "Total",    value: "\(total)",      icon: "doc.text.fill",        color: .blue)
            StatCard(title: "Diproses", value: "\(inProgress)", icon: "clock.fill",           color: .orange)
            StatCard(title: "Selesai",  value: "\(completed)",  icon: "checkmark.circle.fill", color: .green)
        }
    }
}

// MARK: - StatCard
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle().fill(color.opacity(0.15)).frame(width: 45, height: 45)
                Image(systemName: icon).font(.title3).foregroundColor(color)
            }
            Text(value).font(.title2).fontWeight(.bold)
            Text(title).font(.caption).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - RecentReportsSection
struct RecentReportsSection: View {
    let reports: [ReportModel]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Laporan Terbaru")
                    .font(.headline).fontWeight(.semibold)
                Spacer()
            }
            if reports.isEmpty {
                EmptyReportsCard()
            } else {
                ForEach(reports) { report in
                    ReportCard(report: report)
                }
            }
        }
    }
}

// MARK: - EmptyReportsCard
struct EmptyReportsCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 45)).foregroundColor(.gray)
            Text("Belum ada laporan").font(.subheadline).foregroundColor(.gray)
            Text("Tekan tombol di atas untuk membuat laporan")
                .font(.caption).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

// MARK: - InfoCard
struct InfoCard: View {
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle().fill(Color.green.opacity(0.15)).frame(width: 50, height: 50)
                Image(systemName: "leaf.fill").font(.title2).foregroundColor(.green)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("SDG 6: Air Bersih & Sanitasi")
                    .font(.subheadline).fontWeight(.semibold)
                Text("Laporkan masalah untuk membantu lingkungan yang lebih sehat")
                    .font(.caption).foregroundColor(.gray).lineLimit(2)
            }
            Spacer()
        }
        .padding()
        .background(LinearGradient(colors: [Color.green.opacity(0.1), Color.blue.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(16)
    }
}

// MARK: - ReportCard (shared)
struct ReportCard: View {
    let report: ReportModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                StatusBadge(status: report.status)
                Spacer()
                if report.isUrgent {
                    Label("Darurat", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
                Text(report.reportId)
                    .font(.caption2).foregroundColor(.gray)
            }
            Text(report.title)
                .font(.subheadline).fontWeight(.semibold)
            HStack(spacing: 6) {
                Image(systemName: "location.fill").font(.caption2).foregroundColor(.gray)
                Text(report.location).font(.caption).foregroundColor(.gray).lineLimit(1)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
    }
}

// MARK: - StatusBadge (shared)
struct StatusBadge: View {
    let status: String

    var color: Color {
        switch status {
        case "Pending":     return .orange
        case "Verified":    return .blue
        case "In Progress": return .green
        case "Completed":   return Color(red: 0.2, green: 0.6, blue: 0.2)
        case "Rejected":    return .red
        default:            return .gray
        }
    }

    var displayName: String {
        switch status {
        case "Pending":     return "Menunggu"
        case "Verified":    return "Diverifikasi"
        case "In Progress": return "Dikerjakan"
        case "Completed":   return "Selesai"
        case "Rejected":    return "Ditolak"
        default:            return status
        }
    }

    var body: some View {
        Text(displayName)
            .font(.caption2).fontWeight(.semibold)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}

// MARK: - PrimaryButton (shared component)
struct PrimaryButton: View {
    let title: String
    let icon: String
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: icon)
                    Text(title).fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(isLoading ? Color.gray : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(isLoading)
    }
}

// MARK: - CustomTextField (shared component)
struct CustomTextField: View {
    let title: String
    let icon: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption).fontWeight(.medium).foregroundColor(.gray)
            HStack {
                Image(systemName: icon).foregroundColor(.gray).frame(width: 24)
                if isSecure {
                    SecureField(title, text: $text)
                } else {
                    TextField(title, text: $text)
                        .keyboardType(keyboardType)
                        .autocapitalization(keyboardType == .emailAddress ? .none : .sentences)
                }
            }
            .padding(.vertical, 12).padding(.horizontal, 4)
            .background(Rectangle().fill(Color(.systemGray5)).frame(height: 1), alignment: .bottom)
        }
    }
}

// MARK: - ResidentReportHistoryView
struct ResidentReportHistoryView: View {
    @EnvironmentObject var authController:   AuthController
    @EnvironmentObject var reportController: ReportController
    @State private var searchText     = ""
    @State private var selectedFilter = "Semua"

    let filters = ["Semua", "Pending", "In Progress", "Completed"]

    private var myReports: [ReportModel] {
        guard let uid = authController.currentUser?.id else { return [] }
        return reportController.reports(forUser: uid)
    }

    private var filteredReports: [ReportModel] {
        var list = myReports
        if selectedFilter != "Semua" {
            list = list.filter { $0.status == selectedFilter }
        }
        if !searchText.isEmpty {
            list = list.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.location.localizedCaseInsensitiveContains(searchText) ||
                $0.reportId.localizedCaseInsensitiveContains(searchText)
            }
        }
        return list
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.gray)
                    TextField("Cari laporan...", text: $searchText).textFieldStyle(PlainTextFieldStyle())
                    if !searchText.isEmpty {
                        Button("Batal") { searchText = "" }.font(.caption).foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)

                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(filters, id: \.self) { f in
                            FilterChip(title: f, isSelected: selectedFilter == f) {
                                withAnimation { selectedFilter = f }
                            }
                        }
                    }
                    .padding(.horizontal).padding(.vertical, 12)
                }

                if filteredReports.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass").font(.system(size: 45)).foregroundColor(.gray)
                        Text("Belum Ada Laporan").font(.headline)
                        Text("Laporan yang kamu buat akan muncul di sini").font(.caption).foregroundColor(.gray)
                    }
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
            .navigationTitle("Laporan Saya")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGray6).ignoresSafeArea())
        }
    }
}

// MARK: - FilterChip (shared)
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline).fontWeight(.medium)
                .padding(.horizontal, 16).padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthController())
        .environmentObject(ReportController())
}
