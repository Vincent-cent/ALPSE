//
//  ContentView.swift
//  shannonfinaltestSEfix
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authController   = AuthController()
    @StateObject private var reportController = ReportController()

    var body: some View {
        Group {
            if authController.isLoggedIn, let user = authController.currentUser {
                // Route berdasarkan role
                switch user.role {
                case "admin":
                    AdminHomeView()
                        .environmentObject(authController)
                        .environmentObject(reportController)
                case "technician":
                    TechnicianHomeView()
                        .environmentObject(authController)
                        .environmentObject(reportController)
                case "community_leader":
                    CommunityLeaderHomeView()
                        .environmentObject(authController)
                        .environmentObject(reportController)
                default:
                    // resident
                    HomeView()
                        .environmentObject(authController)
                        .environmentObject(reportController)
                }
            } else {
                LoginView()
                    .environmentObject(authController)
                    .environmentObject(reportController)
            }
        }
    }
}

#Preview {
    ContentView()
}
