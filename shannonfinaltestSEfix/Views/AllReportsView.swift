//
//  AllReportsView.swift
//  shannonfinaltestSEfix
//
//  Created by Vincent on 02/06/26.
//
import SwiftUI

struct AllReportsView: View {
    @EnvironmentObject var reportController: ReportController
    @State private var selectedFilter = "Semua"

    let filters = ["Semua", "Pending", "In Progress", "Completed"]

    private var filteredReports: [ReportModel] {
        if selectedFilter == "Semua" { return reportController.reports }
        return reportController.reports.filter { $0.status == selectedFilter }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(filters, id: \.self) { f in
                            FilterChip(title: f, isSelected: selectedFilter == f) {
                                withAnimation { selectedFilter = f }
                            }
                        }
                    }
                    .padding(.horizontal).padding(.vertical, 10)
                }

                if filteredReports.isEmpty {
                    Spacer()
                    Text("Tidak ada laporan.").foregroundColor(.gray)
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
            .navigationTitle("Semua Laporan")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGray6).ignoresSafeArea())
        }
    }
}
