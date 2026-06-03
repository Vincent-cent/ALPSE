//
//  VerifyReportView.swift
//  shannonfinaltestSEfix
//
//  Created by Vincent on 02/06/26.
//

import SwiftUI

struct VerifyReportView: View {
    let report: ReportModel

    @EnvironmentObject var reportController: ReportController
    @Environment(\.dismiss) var dismiss

    @State private var showApproveAlert  = false
    @State private var showRejectAlert   = false
    @State private var showSuccessAlert  = false
    @State private var successMessage    = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Informasi Laporan").font(.headline)
                    CLReportCard(report: report)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Deskripsi Masalah").font(.subheadline).fontWeight(.semibold)
                        Text(report.description).font(.body).foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }

                Divider()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Foto Bukti dari Teknisi").font(.headline)
                    if let proofImg = report.proofImage {
                        Image(uiImage: proofImg)
                            .resizable().scaledToFit()
                            .cornerRadius(12)
                    } else {
                        HStack {
                            Image(systemName: "photo.slash").foregroundColor(.gray)
                            Text("Belum ada foto bukti yang dikirim teknisi.")
                                .font(.caption).foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }

                Divider()

                VStack(spacing: 14) {
                    Text("Verifikasi Hasil Pekerjaan").font(.headline)
                    Text("Pilih tindakan berdasarkan hasil verifikasi di lapangan:")
                        .font(.caption).foregroundColor(.gray)

                    Button(action: { showApproveAlert = true }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Setujui — Pekerjaan Selesai").fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }

                    Button(action: { showRejectAlert = true }) {
                        HStack {
                            Image(systemName: "arrow.uturn.backward.circle.fill")
                            Text("Tolak — Kembalikan ke Admin").fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Verifikasi Laporan")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Setujui Pekerjaan?", isPresented: $showApproveAlert) {
            Button("Batal", role: .cancel) { }
            Button("Ya, Setujui") { verify(approved: true) }
        } message: {
            Text("Konfirmasi bahwa pekerjaan pada laporan \(report.reportId) sudah selesai dengan baik.")
        }
        .alert("Tolak & Kembalikan?", isPresented: $showRejectAlert) {
            Button("Batal", role: .cancel) { }
            Button("Ya, Tolak", role: .destructive) { verify(approved: false) }
        } message: {
            Text("Laporan akan dikembalikan ke status Pending dan admin akan diberitahu untuk menugaskan ulang.")
        }
        .alert("Berhasil!", isPresented: $showSuccessAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text(successMessage)
        }
    }

    private func verify(approved: Bool) {
        reportController.verifyCompletion(reportId: report.reportId, approved: approved) { success in
            if success {
                successMessage = approved
                    ? "Laporan \(report.reportId) telah diverifikasi sebagai selesai."
                    : "Laporan \(report.reportId) dikembalikan ke Pending. Admin akan mendapat notifikasi untuk assign ulang."
                showSuccessAlert = true
            }
        }
    }
}
