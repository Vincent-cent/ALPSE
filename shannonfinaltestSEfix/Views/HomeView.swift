//
//  HomeView.swift
//  shannonfinaltestSEfix
//  Halaman utama untuk role: Resident (Warga)
//

import SwiftUI

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

                    ResidentStatsRow(
                        total:      myReports.count,
                        inProgress: myReports.filter { $0.status == "In Progress" }.count,
                        completed:  myReports.filter { $0.status == "Completed" }.count
                    )

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



#Preview {
    HomeView()
        .environmentObject(AuthController())
        .environmentObject(ReportController())
}
