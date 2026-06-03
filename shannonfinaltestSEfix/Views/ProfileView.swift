//
//  ProfileView.swift
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authController:   AuthController
    @EnvironmentObject var reportController: ReportController
    @State private var showLogoutAlert = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    ProfileHeader(user: authController.currentUser)

                    if authController.currentUser?.role == "resident" {
                        let uid = authController.currentUser?.id ?? ""
                        let myReports = reportController.reports(forUser: uid)
                        ResidentStatsRow(
                            total:      myReports.count,
                            inProgress: myReports.filter { $0.status == "In Progress" }.count,
                            completed:  myReports.filter { $0.status == "Completed" }.count
                        )
                        .padding(.horizontal)
                    }

                    VStack(spacing: 12) {
                        if authController.currentUser?.role == "admin" {
                            NavigationLink(destination: CreateEmployeeContent().environmentObject(authController)) {
                                HStack(spacing: 15) {
                                    ZStack {
                                        Circle().fill(Color.indigo.opacity(0.15)).frame(width: 45, height: 45)
                                        Image(systemName: "person.badge.key.fill").font(.title3).foregroundColor(.indigo)
                                    }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Buat Akun Pegawai").font(.subheadline).fontWeight(.semibold).foregroundColor(.primary)
                                        Text("Tambah Teknisi, Admin, atau Ketua RT/RW").font(.caption).foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                            }
                        }

                        ProfileMenuItem(
                            icon: "info.circle.fill",
                            title: "Tentang AquaAlert",
                            subtitle: "SDG 6 — Air Bersih & Sanitasi",
                            color: .green
                        ) { }

                        ProfileMenuItem(
                            icon: "envelope.fill",
                            title: "Bantuan & Dukungan",
                            subtitle: "Hubungi tim kami",
                            color: .purple
                        ) { }
                    }
                    .padding(.horizontal)

                    Button(action: { showLogoutAlert = true }) {
                        HStack {
                            Image(systemName: "arrow.right.square").font(.headline)
                            Text("Logout").fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    Text("AquaAlert v1.0.0")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 10)

                    Spacer(minLength: 30)
                }
                .padding(.vertical)
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.large)
            .alert("Konfirmasi Logout", isPresented: $showLogoutAlert) {
                Button("Batal", role: .cancel) { }
                Button("Logout", role: .destructive) { authController.logout() }
            } message: {
                Text("Apakah Anda yakin ingin keluar?")
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthController())
        .environmentObject(ReportController())
}
