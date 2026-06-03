//
//  ReportFormView.swift
//

import SwiftUI

extension Notification.Name {
    static let switchToLaporanTab = Notification.Name("switchToLaporanTab")
}

struct ReportFormView: View {
    @State private var selectedCategory = "Pipa Bocor"
    @State private var location         = ""
    @State private var description      = ""
    @State private var isUrgent         = false
    @State private var showImagePicker  = false
    @State private var selectedImage:   UIImage?
    @State private var showSuccess      = false
    @State private var showError        = false
    @State private var errorMessage     = ""

    @EnvironmentObject var reportController: ReportController
    @EnvironmentObject var authController:   AuthController
    @Environment(\.dismiss) var dismiss

    let categories = ReportCategory.allCategories

    var isFormValid: Bool {
        !location.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title3)
                            Text("Isi form berikut untuk melaporkan masalah air atau sanitasi di lingkungan Anda")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding()
                        .background(Color.blue.opacity(0.08))
                        .cornerRadius(12)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Jenis Masalah")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(categories, id: \.name) { cat in
                                        Button(action: { selectedCategory = cat.name }) {
                                            HStack(spacing: 8) {
                                                Image(systemName: cat.icon).font(.caption)
                                                Text(cat.name)
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(selectedCategory == cat.name ? cat.color : Color(.systemGray5))
                                            .foregroundColor(selectedCategory == cat.name ? .white : .primary)
                                            .cornerRadius(25)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Lokasi Kejadian")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("(Wajib)")
                                    .font(.caption2)
                                    .foregroundColor(.red)
                            }
                            HStack {
                                Image(systemName: "location.fill")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                                TextField("Contoh: Jl. Mawar No.5, RT02/RW03", text: $location)
                                    .textFieldStyle(PlainTextFieldStyle())
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Deskripsi Masalah")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("(Wajib)")
                                    .font(.caption2)
                                    .foregroundColor(.red)
                            }
                            TextEditor(text: $description)
                                .frame(minHeight: 100)
                                .padding(8)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            Text("Jelaskan secara detail agar petugas cepat merespon")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Foto Bukti")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Button(action: { showImagePicker = true }) {
                                if let img = selectedImage {
                                    ZStack(alignment: .topTrailing) {
                                        Image(uiImage: img)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 180)
                                            .cornerRadius(12)
                                        Button(action: { selectedImage = nil }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.title2)
                                                .foregroundColor(.white)
                                                .background(Circle().fill(Color.black.opacity(0.6)))
                                        }
                                        .padding(8)
                                    }
                                } else {
                                    HStack {
                                        Image(systemName: "camera.fill")
                                            .font(.title2)
                                            .foregroundColor(.blue)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Tambah Foto")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Text("Pilih dari galeri")
                                                .font(.caption2)
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
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Prioritas Darurat")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("Centang jika masalah sangat mendesak")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Toggle("", isOn: $isUrgent)
                                .toggleStyle(SwitchToggleStyle(tint: .red))
                        }
                        .padding()
                        .background(isUrgent ? Color.red.opacity(0.1) : Color(.systemBackground))
                        .cornerRadius(12)

                        Button(action: submitReport) {
                            HStack(spacing: 12) {
                                if reportController.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "paperplane.fill")
                                    Text("Kirim Laporan").fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(isFormValid && !reportController.isLoading ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(!isFormValid || reportController.isLoading)

                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("Buat Laporan Baru")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Batal") { dismiss() }.foregroundColor(.blue)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePickerView(image: $selectedImage)
            }
            .alert("Berhasil!", isPresented: $showSuccess) {
                Button("OK") {
                    NotificationCenter.default.post(name: .switchToLaporanTab, object: nil)
                    dismiss()
                }
            } message: {
                Text("Laporan kamu telah dikirim dengan status Pending. Tim kami akan segera memprosesnya. Terima kasih!")
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func submitReport() {
        guard isFormValid else {
            errorMessage = "Mohon lengkapi lokasi dan deskripsi"
            showError = true
            return
        }

        let userId = authController.currentUser?.id ?? ""

        reportController.addReport(
            title:             selectedCategory,
            category:          selectedCategory,
            location:          location,
            description:       description,
            image:             selectedImage,
            isUrgent:          isUrgent,
            submittedByUserId: userId
        ) { success in
            if success {
                showSuccess = true
            } else {
                errorMessage = "Gagal mengirim laporan. Coba lagi."
                showError = true
            }
        }
    }
}

#Preview {
    ReportFormView()
        .environmentObject(ReportController())
        .environmentObject(AuthController())
}
