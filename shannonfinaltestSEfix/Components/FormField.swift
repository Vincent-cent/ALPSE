//
//  FormField.swift
//  shannonfinaltestSEfix
//
//  Created by Vincent on 02/06/26.
//
import SwiftUI

struct FormField: View {
    let label: String
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isEmail: Bool  = false
    var isSecure: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.caption).fontWeight(.medium).foregroundColor(.gray)
            HStack {
                Image(systemName: icon).foregroundColor(.gray).frame(width: 24)
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                        .autocapitalization(isEmail ? .none : .words)
                        .keyboardType(isEmail ? .emailAddress : .default)
                }
            }
            .padding(.vertical, 12).padding(.horizontal, 4)
            .background(Rectangle().fill(Color(.systemGray5)).frame(height: 1), alignment: .bottom)
        }
    }
}
