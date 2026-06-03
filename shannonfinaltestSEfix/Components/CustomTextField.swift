//
//  CustomTextField.swift
//  shannonfinaltestSEfix
//
//  Created by Vincent on 02/06/26.
//
import SwiftUI

struct CustomTextField: View {
    let title: String
    let icon: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption).fontWeight(.medium).foregroundColor(.gray)
            HStack {
                Image(systemName: icon).foregroundColor(.gray).frame(width: 24)
                if isSecure {
                    SecureField(title, text: $text)
                } else {
                    TextField(title, text: $text)
                        .keyboardType(keyboardType)
                        .autocapitalization(keyboardType == .emailAddress ? .none : .sentences)
                }
            }
            .padding(.vertical, 12).padding(.horizontal, 4)
            .background(Rectangle().fill(Color(.systemGray5)).frame(height: 1), alignment: .bottom)
        }
    }
}

