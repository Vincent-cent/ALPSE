//
//  ProfileView.swift
//  shannonfinaltestSEfix
//  Dipakai oleh semua role (resident, admin, technician, community_leader)
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

                    // Stats hanya untuk resident
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

                    // Menu items
                    VStack(spacing: 12) {
                        // Khusus Admin: shortcut ke Buat Akun Pegawai
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

                    // Logout
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

// MARK: - ProfileHeader
struct ProfileHeader: View {
    let user: UserModel?

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [roleColor, roleColor.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: roleColor.opacity(0.3), radius: 10, x: 0, y: 5)
                Text(user?.name.prefix(1).uppercased() ?? "U")
                    .font(.system(size: 45))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }

            VStack(spacing: 6) {
                Text(user?.name ?? "Pengguna")
                    .font(.title2)
                    .fontWeight(.bold)
                HStack {
                    Image(systemName: roleIcon).font(.caption)
                    Text(user?.roleDisplayName ?? "Warga").font(.subheadline)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(roleColor.opacity(0.1))
                .foregroundColor(roleColor)
                .cornerRadius(15)
            }

            HStack {
                Image(systemName: "envelope")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(user?.email ?? "user@example.com")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
    }

    var roleIcon: String {
        switch user?.role {
        case "admin":            return "shield.fill"
        case "technician":       return "wrench.fill"
        case "community_leader": return "person.3.fill"
        default:                 return "person.fill"
        }
    }

    var roleColor: Color {
        switch user?.role {
        case "admin":            return .indigo
        case "technician":       return .green
        case "community_leader": return .purple
        default:                 return .blue
        }
    }
}

// MARK: - ProfileMenuItem
struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 45, height: 45)
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthController())
        .environmentObject(ReportController())
}
