//
//  ReportDetailView.swift
//  shannonfinaltestSEfix
//
//  Created by Vincent on 02/06/26.
//

import SwiftUI

struct ReportDetailView: View {
    let report: ReportModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(report.reportId)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(report.title)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    StatusBadge(status: report.status)
                }

                Divider()

                DetailRow(icon: "tag.fill",      title: "Kategori",        value: report.category,            color: .blue)
                DetailRow(icon: "location.fill",  title: "Lokasi",          value: report.location,            color: .orange)
                DetailRow(icon: "calendar",       title: "Tanggal Laporan", value: formattedDate(report.date), color: .green)

                if !report.assignedTechnicianName.isEmpty {
                    DetailRow(icon: "wrench.fill", title: "Teknisi", value: report.assignedTechnicianName, color: .teal)
                }

                if report.isUrgent {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text("Laporan Prioritas Darurat")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Deskripsi").font(.headline)
                    Text(report.description)
                        .font(.body)
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let img = report.image {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Foto Laporan").font(.headline)
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                    }
                } else if let urlString = report.imageUrl, let url = URL(string: urlString) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Foto Laporan").font(.headline)
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(maxWidth: .infinity, minHeight: 180)
                            case .success(let image):
                                image.resizable().scaledToFit().cornerRadius(12)
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

                if let proofImg = report.proofImage {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Foto Bukti Teknisi").font(.headline)
                        Image(uiImage: proofImg)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                    }
                } else if let urlString = report.proofImageUrl, let url = URL(string: urlString) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Foto Bukti Teknisi").font(.headline)
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(maxWidth: .infinity, minHeight: 180)
                            case .success(let image):
                                image.resizable().scaledToFit().cornerRadius(12)
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

                VStack(alignment: .leading, spacing: 15) {
                    Text("Status Timeline")
                        .font(.headline)
                        .padding(.top, 10)

                    TimelineItem(
                        status: "Laporan Dikirim",
                        isCompleted: true,
                        date: report.date
                    )
                    TimelineItem(
                        status: "Sedang Dikerjakan",
                        isCompleted: report.status == "In Progress" || report.status == "Completed",
                        date: report.status != "Pending" ? report.date : nil
                    )
                    TimelineItem(
                        status: "Selesai",
                        isCompleted: report.status == "Completed",
                        date: report.status == "Completed" ? report.date : nil
                    )
                }

                Spacer(minLength: 50)
            }
            .padding()
        }
        .navigationTitle("Detail Laporan")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd MMMM yyyy, HH:mm"
        f.locale = Locale(identifier: "id_ID")
        return f.string(from: date)
    }
}
