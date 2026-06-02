//
//  UserModel.swift
//
//  Created by Vincent on 02/06/26.
//

import Foundation
import SwiftUI

struct UserModel : Identifiable{
    let id: String
    let name: String
    let email: String
    let role: String
    let avatarColor: Color

    var roleDisplayName: String {
        switch role {
        case "resident":         return "Warga"
        case "community_leader": return "Ketua RT/RW"
        case "admin":            return "Admin"
        case "technician":       return "Teknisi"
        default:                 return "Warga"
        }
    }

    init(id: String, name: String, email: String, role: String, avatarColor: Color? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.avatarColor = avatarColor ?? {
            let colors: [Color] = [.blue, .green, .orange, .purple, .pink]
            return colors[abs(name.hashValue) % colors.count]
        }()
    }
}
