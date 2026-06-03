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



#Preview {
    TechnicianHomeView()
        .environmentObject(AuthController())
        .environmentObject(ReportController())
}
