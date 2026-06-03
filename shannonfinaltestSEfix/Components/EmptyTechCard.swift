//
//  EmptyTechCard.swift
//  shannonfinaltestSEfix
//
//  Created by Vincent on 02/06/26.
//
import SwiftUI

struct EmptyTechCard: View {
    let message: String

    var body: some View {
        HStack {
            Image(systemName: "checkmark.seal.fill").foregroundColor(.green)
            Text(message).font(.caption).foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}
