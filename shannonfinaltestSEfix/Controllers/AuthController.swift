//
//  AuthController.swift
//  shannonfinaltestSEfix
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthController: ObservableObject {
    @Published var currentUser: UserModel?
    @Published var isLoggedIn  = false
    @Published var isLoading   = false
    @Published var errorMessage: String?

    // List teknisi untuk dropdown assign (dipakai Admin)
    @Published var technicians: [UserModel] = []

    private let db = Firestore.firestore()

    init() {
        if let firebaseUser = Auth.auth().currentUser {
            fetchUserData(uid: firebaseUser.uid)
        }
    }

    // MARK: - Register (untuk warga / publik)
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

    // MARK: - Admin buat akun pegawai (tanpa mengubah session yang sedang login)
    func createEmployeeAccount(
        username: String,
        email: String,
        password: String,
        role: String,
        completion: @escaping (Bool, String) -> Void
    ) {
        isLoading = true

        // Simpan current user session
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
                // Sign out the newly created user, sign back in admin
                try? Auth.auth().signOut()
                if let adminUser = currentFirebaseUser {
                    // Re-fetch admin data to restore session
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

    // MARK: - Login
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
            guard let uid = result?.user.uid else { return }
            self.fetchUserData(uid: uid)
        }
    }

    // MARK: - Logout
    func logout() {
        try? Auth.auth().signOut()
        DispatchQueue.main.async {
            self.currentUser = nil
            self.isLoggedIn  = false
        }
    }

    // MARK: - Fetch user data
    func fetchUserData(uid: String) {
        db.collection("users").document(uid).getDocument { doc, error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let doc = doc, doc.exists, let data = doc.data() {
                    let id    = data["id"]    as? String ?? uid
                    let name  = data["name"]  as? String ?? ""
                    let email = data["email"] as? String ?? ""
                    let role  = data["role"]  as? String ?? "resident"
                    self.currentUser = UserModel(id: id, name: name, email: email, role: role)
                    self.isLoggedIn  = true
                } else {
                    self.errorMessage = "Gagal memuat profil akun."
                }
            }
        }
    }

    // MARK: - Fetch semua teknisi (untuk admin assign)
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

    // MARK: - Error helper
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
