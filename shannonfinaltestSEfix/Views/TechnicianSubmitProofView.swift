//
//  TechnicianSubmitProofView.swift
//  shannonfinaltestSEfix
//
//  Created by Vincent on 02/06/26.
//
import SwiftUI
import Combine

struct TechnicianSubmitProofView: View {
    let report: ReportModel

    @EnvironmentObject var reportController: ReportController
    @Environment(\.dismiss) var dismiss

    @State private var proofImage:     UIImage?
    @State private var showImagePicker = false
    @State private var showSuccess     = false
    @State private var showError       = false
    @State private var errorMsg        = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Detail Laporan").font(.headline)
                    TechnicianReportCard(report: report)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Deskripsi Masalah").font(.subheadline).fontWeight(.semibold)
                        Text(report.description).font(.body).foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    if let img = report.image {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Foto Laporan dari Warga").font(.subheadline).fontWeight(.semibold)
                            Image(uiImage: img)
                                .resizable().scaledToFit()
                                .cornerRadius(10)
                        }
                    } else if let urlString = report.imageUrl, let url = URL(string: urlString) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Foto Laporan dari Warga").font(.subheadline).fontWeight(.semibold)
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(maxWidth: .infinity, minHeight: 180)
                                case .success(let image):
                                    image.resizable().scaledToFit().cornerRadius(10)
                                case .failure:
                                    Image(systemName: "photo")
                                        .foregroundColor(.gray)
                                        .frame(maxWidth: .infinity, minHeight: 180)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                }

                Divider()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Upload Foto Bukti Pengerjaan").font(.headline)
                    Text("Ambil atau pilih foto setelah pekerjaan selesai sebagai bukti.")
                        .font(.caption).foregroundColor(.gray)

                    Button(action: { showImagePicker = true }) {
                        if let img = proofImage {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: img)
                                    .resizable().scaledToFit()
                                    .frame(height: 200)
                                    .cornerRadius(12)
                                Button(action: { proofImage = nil }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2).foregroundColor(.white)
                                        .background(Circle().fill(Color.black.opacity(0.6)))
                                }
                                .padding(8)
                            }
                        } else {
                            HStack {
                                Image(systemName: "camera.fill").font(.title2).foregroundColor(.green)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Tambah Foto Bukti").font(.subheadline).fontWeight(.medium)
                                    Text("Pilih dari galeri atau ambil foto").font(.caption2).foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right").font(.caption).foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }

                Button(action: submitProof) {
                    HStack {
                        if reportController.isLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Tandai Selesai & Kirim Bukti").fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(reportController.isLoading ? Color.gray : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(reportController.isLoading)
            }
            .padding()
        }
        .navigationTitle("Submit Bukti")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(image: $proofImage)
        }
        .alert("Berhasil!", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Pekerjaan telah ditandai selesai. Foto bukti telah dikirim. Ketua RT/RW akan memverifikasi hasilnya.")
        }
        .alert("Gagal", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMsg)
        }
    }

    private func submitProof() {
        guard proofImage != nil else {
            errorMsg = "Harap pilih foto bukti pengerjaan terlebih dahulu."
            showError = true
            return
        }
        reportController.submitProof(reportId: report.reportId, proofImage: proofImage) { success in
            if success { showSuccess = true }
            else { errorMsg = "Gagal mengirim bukti. Coba lagi."; showError = true }
        }
    }
}
