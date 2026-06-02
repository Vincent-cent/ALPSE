//
//  MenuCard.swift
//  shannonfinaltestSEfix
//
//  Component card generik untuk menu navigasi
//

import SwiftUI

struct MenuCard: View {
    let icon: String
    let title: String
    let color: Color
    let subtitle: String?

    init(icon: String, title: String, color: Color, subtitle: String? = nil) {
        self.icon     = icon
        self.title    = title
        self.color    = color
        self.subtitle = subtitle
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 55, height: 55)

                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}
