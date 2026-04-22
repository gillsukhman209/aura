import Foundation
import FirebaseAuth
import FirebaseFirestore
import Observation

enum AuthError: LocalizedError {
    case usernameTaken
    case invalidUsername
    case notSignedIn
    case underlying(Error)

    var errorDescription: String? {
        switch self {
        case .usernameTaken: return "That username is already taken."
        case .invalidUsername: return "Usernames must be 3–20 characters: letters, numbers, or underscores."
        case .notSignedIn: return "You're not signed in yet."
        case .underlying(let e): return e.localizedDescription
        }
    }
}

@Observable
final class AuthService {
    static let shared = AuthService()
    private init() {}

    private(set) var currentUID: String?
    private(set) var currentUsername: String?
    private(set) var isReady: Bool = false

    private var authListener: AuthStateDidChangeListenerHandle?
    private let fb = FirebaseService.shared

    /// Anonymous sign-in + listen for auth state. Must be called after FirebaseService.configure().
    func bootstrap() {
        // Firebase disabled — pretend auth is complete so the main UI unlocks.
        if !FirebaseService.enabled {
            Task { @MainActor in
                self.currentUID = "local-debug"
                self.currentUsername = "debug"
                self.isReady = true
            }
            return
        }

        authListener = fb.auth.addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            Task { @MainActor in
                if let user {
                    self.currentUID = user.uid
                    await self.loadUsername()
                    self.isReady = true
                } else {
                    self.currentUID = nil
                    self.currentUsername = nil
                    do {
                        _ = try await self.fb.auth.signInAnonymously()
                    } catch {
                        print("Anonymous sign-in failed: \(error)")
                        self.isReady = true
                    }
                }
            }
        }
    }

    @MainActor
    private func loadUsername() async {
        guard let uid = currentUID else { return }
        do {
            let snap = try await fb.userDoc(uid).getDocument()
            currentUsername = snap.data()?["username"] as? String
        } catch {
            print("loadUsername failed: \(error)")
        }
    }

    /// Validate + reserve username atomically, then create the user doc (merged with migration payload if provided).
    /// Returns the claimed username on success.
    @discardableResult
    func claimUsername(_ raw: String, migrationPayload: [String: Any] = [:]) async throws -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard Self.isValidUsername(trimmed) else { throw AuthError.invalidUsername }

        // Firebase disabled — just accept the username locally for screenshots.
        if !FirebaseService.enabled {
            await MainActor.run { self.currentUsername = trimmed }
            return trimmed
        }

        guard let uid = currentUID else { throw AuthError.notSignedIn }

        let lower = trimmed.lowercased()
        let db = fb.db
        let usernameRef = fb.usernameDoc(lower)
        let userRef = fb.userDoc(uid)

        // Reserve the username atomically.
        _ = try await db.runTransaction({ txn, errorPointer -> Any? in
            do {
                let existing = try txn.getDocument(usernameRef)
                if existing.exists {
                    errorPointer?.pointee = NSError(
                        domain: "AuraAuth",
                        code: 409,
                        userInfo: [NSLocalizedDescriptionKey: "Username taken"]
                    )
                    return nil
                }
                txn.setData([
                    "uid": uid,
                    "createdAt": FieldValue.serverTimestamp()
                ], forDocument: usernameRef)

                var userData: [String: Any] = migrationPayload
                userData["uid"] = uid
                userData["username"] = trimmed
                userData["usernameLower"] = lower
                userData["updatedAt"] = FieldValue.serverTimestamp()
                if userData["createdAt"] == nil {
                    userData["createdAt"] = FieldValue.serverTimestamp()
                }
                if userData["weekResetKey"] == nil {
                    userData["weekResetKey"] = WeekKey.current()
                }
                if userData["weeklyXP"] == nil {
                    userData["weeklyXP"] = 0
                }
                txn.setData(userData, forDocument: userRef, merge: true)
                return nil
            } catch {
                errorPointer?.pointee = error as NSError
                return nil
            }
        })

        await MainActor.run { self.currentUsername = trimmed }
        return trimmed
    }

    static func isValidUsername(_ s: String) -> Bool {
        let pattern = "^[A-Za-z0-9_]{3,20}$"
        return s.range(of: pattern, options: .regularExpression) != nil
    }
}
