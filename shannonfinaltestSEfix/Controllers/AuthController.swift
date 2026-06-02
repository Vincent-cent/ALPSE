//
//  AuthController.swift
//  shannonfinaltestSEfix
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthController: ObservableObject {
    @Published var currentUser: UserModel?
    @Published var isLoggedIn  = false
    @Published var isLoading   = false
    @Published var errorMessage: String?

    @Published var technicians: [UserModel] = []

    private let db = Firestore.firestore()

    init() {
        if let firebaseUser = Auth.auth().currentUser {
            fetchUserData(uid: firebaseUser.uid)
        }
    }

    func registerEmail(username: String, email: String, password: String, role: String, completion: ((Bool) -> Void)? = nil) {
        isLoading = true
        errorMessage = nil

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = self.friendlyError(error)
                    completion?(false)
                }
                return
            }
            guard let uid = result?.user.uid else { completion?(false); return }

            let userData: [String: Any] = ["id": uid, "name": username, "email": email, "role": role]
            self.db.collection("users").document(uid).setData(userData) { err in
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let err = err {
                        self.errorMessage = err.localizedDescription
                        completion?(false)
                    } else {
                        self.currentUser = UserModel(id: uid, name: username, email: email, role: role)
                        self.isLoggedIn  = true
                        completion?(true)
                    }
                }
            }
        }
    }

    func createEmployeeAccount(
        username: String,
        email: String,
        password: String,
        role: String,
        completion: @escaping (Bool, String) -> Void
    ) {
        isLoading = true

        let currentFirebaseUser = Auth.auth().currentUser

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    completion(false, self.friendlyError(error))
                }
                return
            }
            guard let uid = result?.user.uid else {
                completion(false, "Gagal membuat akun.")
                return
            }

            let userData: [String: Any] = ["id": uid, "name": username, "email": email, "role": role]
            self.db.collection("users").document(uid).setData(userData) { err in
                try? Auth.auth().signOut()
                if let adminUser = currentFirebaseUser {
                    self.fetchUserData(uid: adminUser.uid)
                }
                DispatchQueue.main.async {
                    self.isLoading = false
                    if let err = err {
                        completion(false, err.localizedDescription)
                    } else {
                        completion(true, "Akun \(username) berhasil dibuat sebagai \(role).")
                    }
                }
            }
        }
    }

    func loginEmail(email: String, password: String) {
        isLoading = true
        errorMessage = nil

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = self.friendlyError(error)
                }
                return
            }
            guard let uid = result?.user.uid else {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Gagal mendapatkan data akun."
                }
                return
            }
            self.fetchUserData(uid: uid)
        }
    }

    func logout() {
        try? Auth.auth().signOut()
        DispatchQueue.main.async {
            self.currentUser = nil
            self.isLoggedIn  = false
        }
    }

    func fetchUserData(uid: String) {
        db.collection("users").document(uid).getDocument { doc, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Gagal memuat profil: \(error.localizedDescription)"
                    try? Auth.auth().signOut()
                    return
                }

                guard let doc = doc, doc.exists, let data = doc.data() else {
                    self.errorMessage = "Data akun tidak ditemukan di server. Pastikan akun sudah dibuat dengan benar."
                    try? Auth.auth().signOut()
                    return
                }

                let id    = data["id"]    as? String ?? uid
                let name  = data["name"]  as? String ?? ""
                let email = data["email"] as? String ?? ""
                let rawRole = (data["role"] as? String ?? "resident")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .lowercased()

                let role: String
                switch rawRole {
                case "admin":                          role = "admin"
                case "technician", "teknisi":          role = "technician"
                case "community_leader",
                     "community leader",
                     "ketua rt/rw",
                     "ketua rtrw",
                     "ketua rt",
                     "communityleader":                role = "community_leader"
                case "resident", "warga":              role = "resident"
                default:                               role = "resident"
                }

                self.currentUser = UserModel(id: id, name: name, email: email, role: role)
                self.isLoggedIn  = true
            }
        }
    }

    func fetchTechnicians() {
        db.collection("users").whereField("role", isEqualTo: "technician").getDocuments { snapshot, _ in
            guard let docs = snapshot?.documents else { return }
            DispatchQueue.main.async {
                self.technicians = docs.compactMap { doc in
                    let data = doc.data()
                    guard let id = data["id"] as? String,
                          let name = data["name"] as? String,
                          let email = data["email"] as? String,
                          let role = data["role"] as? String
                    else { return nil }
                    return UserModel(id: id, name: name, email: email, role: role)
                }
            }
        }
    }

    private func friendlyError(_ error: Error) -> String {
        let code = (error as NSError).code
        switch code {
        case 17007: return "Email sudah terdaftar. Gunakan email lain."
        case 17008: return "Format email tidak valid."
        case 17026: return "Password harus minimal 6 karakter."
        case 17009: return "Password salah. Coba lagi."
        case 17011: return "Email belum terdaftar."
        default:    return error.localizedDescription
        }
    }
}
