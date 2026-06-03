//
//  CreateEmployeeContent.swift
//  shannonfinaltestSEfix
//
//  Created by Vincent on 02/06/26.
//

import SwiftUI


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
