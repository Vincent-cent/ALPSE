//
//  LoginView.swift
//  shannonfinaltestSEfix
//
//  Halaman login
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @EnvironmentObject var authController: AuthController
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        
                        VStack(spacing: 16) {
                            
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.blue, Color.cyan],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                    .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                                
                                Image(systemName: "drop.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)
                            }
                            
                            Text("AquaAlert")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                            
                            Text("Laporkan Masalah Air & Sanitasi")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 40)
                        
                        
                        VStack(spacing: 24) {
                            CustomTextField(
                                title: "Email",
                                icon: "envelope",
                                text: $email,
                                keyboardType: .emailAddress
                            )
                            
                            CustomTextField(
                                title: "Password",
                                icon: "lock",
                                text: $password,
                                isSecure: true
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        
                        PrimaryButton(
                            title: "Login",
                            icon: "arrow.right",
                            isLoading: authController.isLoading
                        ) {
                            login()
                        }
                        .padding(.horizontal, 24)
                        
                        
                        HStack {
                            Text("Belum punya akun?")
                                .foregroundColor(.gray)
                            
                            Button("Daftar Sekarang") {
                                showRegister = true
                            }
                            .foregroundColor(.blue)
                            .fontWeight(.semibold)
                        }
                        .padding(.top, 8)
                        
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showRegister) {
                RegisterView()
                    .environmentObject(authController)
            }
            .alert("Info", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }.onChange(of: authController.errorMessage) { newValue in
                if let errorMessage = newValue {
                    alertMessage = errorMessage
                    showAlert = true
                }
            }
        }
    }
    
    private func login() {
        if email.isEmpty || password.isEmpty {
                alertMessage = "Email dan password harus diisi"
                showAlert = true
                return
            }
        
        authController.loginEmail(email: email, password: password)
    }
}

#Preview {
    LoginView()
}
