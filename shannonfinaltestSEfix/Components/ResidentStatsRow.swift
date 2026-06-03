//
//  ResidentStatsRow.swift
//  shannonfinaltestSEfix
//
//  Created by Vincent on 02/06/26.
//
import SwiftUI

struct ResidentStatsRow: View {
    let total: Int
    let inProgress: Int
    let completed: Int

    var body: some View {
        HStack(spacing: 15) {
            StatCard(title: "Total",    value: "\(total)",      icon: "doc.text.fill",        color: .blue)
            StatCard(title: "Diproses", value: "\(inProgress)", icon: "clock.fill",           color: .orange)
            StatCard(title: "Selesai",  value: "\(completed)",  icon: "checkmark.circle.fill", color: .green)
        }
    }
}
