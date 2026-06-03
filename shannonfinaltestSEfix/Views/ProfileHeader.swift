//
//  ProfileHeader.swift
//  shannonfinaltestSEfix
//
//  Created by Vincent on 02/06/26.
//

import SwiftUI

struct ProfileHeader: View {
    let user: UserModel?

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [roleColor, roleColor.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: roleColor.opacity(0.3), radius: 10, x: 0, y: 5)
                Text(user?.name.prefix(1).uppercased() ?? "U")
                    .font(.system(size: 45))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }

            VStack(spacing: 6) {
                Text(user?.name ?? "Pengguna")
                    .font(.title2)
                    .fontWeight(.bold)
                HStack {
                    Image(systemName: roleIcon).font(.caption)
                    Text(user?.roleDisplayName ?? "Warga").font(.subheadline)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 5)
                .background(roleColor.opacity(0.1))
                .foregroundColor(roleColor)
                .cornerRadius(15)
            }

            HStack {
                Image(systemName: "envelope")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(user?.email ?? "user@example.com")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
    }

    var roleIcon: String {
        switch user?.role {
        case "admin":            return "shield.fill"
        case "technician":       return "wrench.fill"
        case "community_leader": return "person.3.fill"
        default:                 return "person.fill"
        }
    }

    var roleColor: Color {
        switch user?.role {
        case "admin":            return .indigo
        case "technician":       return .green
        case "community_leader": return .purple
        default:                 return .blue
        }
    }
}
