//
//  ReportHistoryView.swift
//

import SwiftUI

struct ReportHistoryView: View {
    @EnvironmentObject var reportController: ReportController
    @State private var searchText     = ""
    @State private var selectedFilter = "Semua"

    let filters = ["Semua", "Pending", "In Progress", "Completed"]

    var filteredReports: [ReportModel] {
        var list = reportController.reports
        if selectedFilter != "Semua" {
            list = list.filter { $0.status == selectedFilter }
        }
        if !searchText.isEmpty {
            list = list.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.location.localizedCaseInsensitiveContains(searchText) ||
                $0.reportId.localizedCaseInsensitiveContains(searchText)
            }
        }
        return list
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.gray)
                    TextField("Cari laporan...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    if !searchText.isEmpty {
                        Button("Batal") { searchText = "" }
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.top, 8)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(filters, id: \.self) { f in
                            FilterChip(title: f, isSelected: selectedFilter == f) {
                                withAnimation { selectedFilter = f }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }

                if filteredReports.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 45))
                            .foregroundColor(.gray)
                        Text("Belum Ada Laporan")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Belum ada laporan yang sesuai filter")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(filteredReports) { report in
                            NavigationLink(destination: ReportDetailView(report: report)) {
                                ReportCard(report: report)
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Riwayat Laporan")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGray6).ignoresSafeArea())
        }
    }
}

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
                }

                if let proofImg = report.proofImage {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Foto Bukti Teknisi").font(.headline)
                        Image(uiImage: proofImg)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
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

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 35, height: 35)
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            Spacer()
        }
    }
}

struct TimelineItem: View {
    let status: String
    let isCompleted: Bool
    let date: Date?

    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(isCompleted ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 24, height: 24)
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Circle()
                        .fill(Color.gray)
                        .frame(width: 8, height: 8)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(status)
                    .font(.subheadline)
                    .fontWeight(isCompleted ? .semibold : .regular)
                    .foregroundColor(isCompleted ? .primary : .gray)
                if let date = date, isCompleted {
                    Text(formattedDate(date))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd MMM yyyy, HH:mm"
        f.locale = Locale(identifier: "id_ID")
        return f.string(from: date)
    }
}

#Preview {
    ReportHistoryView()
        .environmentObject(ReportController())
}
