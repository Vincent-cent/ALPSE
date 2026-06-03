//
//  ResidentReportHistoryView.swift
//  shannonfinaltestSEfix
//
//  Created by Vincent on 02/06/26.
//
import SwiftUI

struct ResidentReportHistoryView: View {
    @EnvironmentObject var authController:   AuthController
    @EnvironmentObject var reportController: ReportController
    @State private var searchText     = ""
    @State private var selectedFilter = "Semua"

    let filters = ["Semua", "Pending", "In Progress", "Completed"]

    private var myReports: [ReportModel] {
        guard let uid = authController.currentUser?.id else { return [] }
        return reportController.reports(forUser: uid)
    }

    private var filteredReports: [ReportModel] {
        var list = myReports
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
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass").foregroundColor(.gray)
                    TextField("Cari laporan...", text: $searchText).textFieldStyle(PlainTextFieldStyle())
                    if !searchText.isEmpty {
                        Button("Batal") { searchText = "" }.font(.caption).foregroundColor(.blue)
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
                    .padding(.horizontal).padding(.vertical, 12)
                }

                if filteredReports.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text.magnifyingglass").font(.system(size: 45)).foregroundColor(.gray)
                        Text("Belum Ada Laporan").font(.headline)
                        Text("Laporan yang kamu buat akan muncul di sini").font(.caption).foregroundColor(.gray)
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
            .navigationTitle("Laporan Saya")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGray6).ignoresSafeArea())
        }
    }
}
