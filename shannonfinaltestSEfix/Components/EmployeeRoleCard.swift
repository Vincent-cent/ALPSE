//
//  EmployeeRoleCard.swift
//  shannonfinaltestSEfix
//
//  Created by Vincent on 02/06/26.
//
import SwiftUI


struct EmployeeRoleCard: View {
    let roleName: String
    let roleIcon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.indigo : Color(.systemGray5))
                        .frame(width: 55, height: 55)
                    Image(systemName: roleIcon)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? .white : .gray)
                }
                Text(roleName)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .indigo : .gray)
            }
            .frame(width: 90)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected ? Color.indigo.opacity(0.08) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color.indigo : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
