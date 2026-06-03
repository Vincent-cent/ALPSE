//
//  AssignTechnicianView.swift
//  shannonfinaltestSEfix
//
//  Created by Vincent on 02/06/26.
//
import SwiftUI

struct AssignTechnicianView: View {
    let report: ReportModel

    @EnvironmentObject var authController:   AuthController
    @EnvironmentObject var reportController: ReportController
    @Environment(\.dismiss) var dismiss

    @State private var selectedTechnicianId   = ""
    @State private var selectedTechnicianName = ""
    @State private var showSuccess = false
    @State private var showError   = false
    @State private var errorMsg    = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Detail Laporan").font(.headline)
                    AdminReportCard(report: report, showAssignButton: false)
                }

                Divider()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Pilih Teknisi").font(.headline)

                    if authController.technicians.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "person.slash").font(.largeTitle).foregroundColor(.gray)
                            Text("Belum ada teknisi terdaftar.\nBuat akun teknisi di tab \"Buat Akun\" terlebih dahulu.")
                                .font(.caption).foregroundColor(.gray).multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Pilih nama teknisi yang tersedia:")
                                .font(.caption).foregroundColor(.gray)

                            Menu {
                                ForEach(authController.technicians) { tech in
                                    Button(action: {
                                        selectedTechnicianId   = tech.id
                                        selectedTechnicianName = tech.name
                                    }) {
                                        HStack {
                                            Text(tech.name)
                                            Spacer()
                                            Text(tech.email).foregroundColor(.gray)
                                        }
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "person.fill").foregroundColor(.indigo)
                                    Text(selectedTechnicianName.isEmpty ? "Pilih Teknisi..." : selectedTechnicianName)
                                        .foregroundColor(selectedTechnicianName.isEmpty ? .gray : .primary)
                                        .fontWeight(selectedTechnicianName.isEmpty ? .regular : .semibold)
                                    Spacer()
                                    Image(systemName: "chevron.up.chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedTechnicianName.isEmpty ? Color.gray.opacity(0.3) : Color.indigo, lineWidth: 1.5)
                                )
                            }

                            if !selectedTechnicianId.isEmpty,
                               let selectedTech = authController.technicians.first(where: { $0.id == selectedTechnicianId }) {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle().fill(Color.indigo).frame(width: 40, height: 40)
                                        Text(String(selectedTech.name.prefix(1)).uppercased())
                                            .font(.headline).fontWeight(.bold).foregroundColor(.white)
                                    }
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(selectedTech.name).font(.subheadline).fontWeight(.semibold)
                                        Text(selectedTech.email).font(.caption).foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Image(systemName: "checkmark.circle.fill").foregroundColor(.indigo)
                                }
                                .padding()
                                .background(Color.indigo.opacity(0.08))
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.indigo, lineWidth: 1))
                            }
                        }
                    }
                }

                Button(action: assignTechnician) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Simpan & Assign Teknisi").fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(selectedTechnicianId.isEmpty ? Color.gray : Color.indigo)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(selectedTechnicianId.isEmpty)
            }
            .padding()
        }
        .navigationTitle("Assign Teknisi")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { authController.fetchTechnicians() }
        .alert("Berhasil!", isPresented: $showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text("Laporan \(report.reportId) telah di-assign ke \(selectedTechnicianName). Status laporan berubah menjadi \"Sedang Dikerjakan\".")
        }
        .alert("Gagal", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMsg)
        }
    }

    private func assignTechnician() {
        reportController.assignTechnician(
            reportId: report.reportId,
            technicianId: selectedTechnicianId,
            technicianName: selectedTechnicianName
        ) { success in
            if success { showSuccess = true }
            else { errorMsg = "Gagal menyimpan. Coba lagi."; showError = true }
        }
    }
}
