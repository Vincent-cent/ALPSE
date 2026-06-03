//
//  TimelineItem.swift
//  shannonfinaltestSEfix
//
//  Created by Vincent on 02/06/26.
//
import SwiftUI

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
