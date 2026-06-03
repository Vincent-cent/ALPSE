//
//  InfoCard.swift
//  shannonfinaltestSEfix
//
//  Created by Vincent on 02/06/26.
//
import SwiftUI

struct InfoCard: View {
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle().fill(Color.green.opacity(0.15)).frame(width: 50, height: 50)
                Image(systemName: "leaf.fill").font(.title2).foregroundColor(.green)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("SDG 6: Air Bersih & Sanitasi")
                    .font(.subheadline).fontWeight(.semibold)
                Text("Laporkan masalah untuk membantu lingkungan yang lebih sehat")
                    .font(.caption).foregroundColor(.gray).lineLimit(2)
            }
            Spacer()
        }
        .padding()
        .background(LinearGradient(colors: [Color.green.opacity(0.1), Color.blue.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
        .cornerRadius(16)
    }
}
