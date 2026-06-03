//
//  StatusTab.swift
//  shannonfinaltestSEfix
//
//  Created by Vincent on 02/06/26.
//
import SwiftUI

struct StatusTab: View {
    let title: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void

    var statusColor: Color {
        switch title {
        case "Pending":     return .orange
        case "In Progress": return .green
        case "Completed":   return Color(red: 0.2, green: 0.6, blue: 0.2)
        case "Rejected":    return .red
        default:            return .blue
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .medium)
                    .foregroundColor(isSelected ? statusColor : .gray)
                Text("\(count)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(isSelected ? statusColor.opacity(0.15) : Color(.systemGray5))
                    .foregroundColor(isSelected ? statusColor : .gray)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(isSelected ? statusColor.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
