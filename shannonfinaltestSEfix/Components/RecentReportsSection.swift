//
//  RecentReportsSection.swift
//  shannonfinaltestSEfix
//
//  Created by Vincent on 02/06/26.
//
import SwiftUI

struct RecentReportsSection: View {
    let reports: [ReportModel]

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Laporan Terbaru")
                    .font(.headline).fontWeight(.semibold)
                Spacer()
            }
            if reports.isEmpty {
                EmptyReportsCard()
            } else {
                ForEach(reports) { report in
                    ReportCard(report: report)
                }
            }
        }
    }
}
