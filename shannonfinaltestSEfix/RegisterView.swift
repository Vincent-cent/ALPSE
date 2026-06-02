//
//  RegisterView.swift
//  shannonfinaltestSEfix
//  Halaman registrasi akun — hanya untuk warga (resident)
//  Admin membuat akun pegawai dari dalam aplikasi (AdminHomeView)
//

import SwiftUI

struct RegisterView: View {
    @State private var name            = ""
    @State private var email           = ""
    @State private var password        = ""
    @State private var confirmPassword = ""
    @State private var showAlert       = false
    @State private var alertMessage    = ""
    @State private var isSuccess       = false

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authController: AuthController

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            ZStack {
                                Circle().fill(Color.blue.opacity(0.15)).frame(width: 80, height: 80)
                                Image(systemName: "person.badge.plus").font(.system(size: 35)).foregroundColor(.blue)
                            }
                            Text("Buat Akun Warga").font(.title2).fontWeight(.bold)
                            Text("Daftar untuk melaporkan masalah air & sanitasi")
                                .font(.caption).foregroundColor(.gray).multilineTextAlignment(.center)
                        }
                        .padding(.top, 20)

                        // Form
                        VStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Nama Lengkap").font(.caption).fontWeight(.medium).foregroundColor(.gray)
                                HStack {
                                    Image(systemName: "person").foregroundColor(.gray).frame(width: 24)
                                    TextField("Masukkan nama lengkap", text: $name)
                                        .textInputAutocapitalization(.words)
                                }
                                .padding(.vertical, 12).padding(.horizontal, 4)
                                .background(Rectangle().fill(Color(.systemGray5)).frame(height: 1), alignment: .bottom)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email").font(.caption).fontWeight(.medium).foregroundColor(.gray)
                                HStack {
                                    Image(systemName: "envelope").foregroundColor(.gray).frame(width: 24)
                                    TextField("email@example.com", text: $email)
                                        .autocapitalization(.none).keyboardType(.emailAddress)
                                }
                                .padding(.vertical, 12).padding(.horizontal, 4)
                                .background(Rectangle().fill(Color(.systemGray5)).frame(height: 1), alignment: .bottom)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password").font(.caption).fontWeight(.medium).foregroundColor(.gray)
                                HStack {
                                    Image(systemName: "lock").foregroundColor(.gray).frame(width: 24)
                                    SecureField("Minimal 6 karakter", text: $password)
                                }
                                .padding(.vertical, 12).padding(.horizontal, 4)
                                .background(Rectangle().fill(Color(.systemGray5)).frame(height: 1), alignment: .bottom)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Konfirmasi Password").font(.caption).fontWeight(.medium).foregroundColor(.gray)
                                HStack {
                                    Image(systemName: "lock.shield").foregroundColor(.gray).frame(width: 24)
                                    SecureField("Ketik ulang password", text: $confirmPassword)
                                }
                                .padding(.vertical, 12).padding(.horizontal, 4)
                                .background(Rectangle().fill(Color(.systemGray5)).frame(height: 1), alignment: .bottom)
                            }
                        }
                        .padding(.horizontal, 24)

                        // Info: role otomatis warga
                        HStack(spacing: 10) {
                            Image(systemName: "info.circle.fill").foregroundColor(.blue)
                            Text("Akun yang didaftarkan di sini akan berperan sebagai **Warga**. Akun Teknisi, Admin, dan Ketua RT/RW dibuat oleh Admin.")
                                .font(.caption).foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.08))
                        .cornerRadius(12)
                        .padding(.horizontal, 24)

                        PrimaryButton(title: "Daftar Sekarang", icon: "checkmark", isLoading: authController.isLoading) {
                            register()
                        }
                        .padding(.horizontal, 24)

                        // Error message
                        if let errMsg = authController.errorMessage {
                            Text(errMsg)
                                .font(.caption).foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }

                        Spacer(minLength: 30)
                    }
                }
            }
            .navigationTitle("Daftar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }.foregroundColor(.blue)
                }
            }
            .alert("Pendaftaran Berhasil!", isPresented: $showAlert) {
                Button("OK") { if isSuccess { dismiss() } }
            } message: {
                Text(alertMessage)
            }
            .onChange(of: authController.isLoggedIn) { loggedIn in
                if loggedIn {
                    isSuccess = true
                    alertMessage = "Akun berhasil dibuat. Selamat datang!"
                    showAlert = true
                }
            }
        }
    }

    private func register() {
        // Reset error
        authController.errorMessage = nil

        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            authController.errorMessage = "Nama lengkap tidak boleh kosong."
            return
        }
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            authController.errorMessage = "Email tidak boleh kosong."
            return
        }
        guard password.count >= 6 else {
            authController.errorMessage = "Password harus minimal 6 karakter."
            return
        }
        guard password == confirmPassword else {
            authController.errorMessage = "Konfirmasi password tidak cocok."
            return
        }

        authController.registerEmail(username: name, email: email, password: password, role: "resident")
    }
}

#Preview {
    RegisterView().environmentObject(AuthController())
}
