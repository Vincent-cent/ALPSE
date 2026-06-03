//
//  EmptyReportsCard.swift
//  shannonfinaltestSEfix
//
//  Created by Vincent on 02/06/26.
//
import SwiftUI

struct EmptyReportsCard: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 45)).foregroundColor(.gray)
            Text("Belum ada laporan").font(.subheadline).foregroundColor(.gray)
            Text("Tekan tombol di atas untuk membuat laporan")
                .font(.caption).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

