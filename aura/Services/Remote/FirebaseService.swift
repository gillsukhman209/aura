import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

final class FirebaseService {
    static let shared = FirebaseService()
    private init() {}

    /// Master kill-switch. Flip to `true` once `GoogleService-Info.plist` is added
    /// and the Firebase console (Anonymous Auth + Firestore) is configured.
    static let enabled = true

    private(set) var isConfigured = false

    func configure() {
        guard Self.enabled else { return }
        guard !isConfigured else { return }
        FirebaseApp.configure()
        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings()
        Firestore.firestore().settings = settings
        isConfigured = true
    }

    var db: Firestore { Firestore.firestore() }
    var auth: Auth { Auth.auth() }

    // Collection refs
    var usersCol: CollectionReference { db.collection("users") }
    var usernamesCol: CollectionReference { db.collection("usernames") }
    var friendRequestsCol: CollectionReference { db.collection("friendRequests") }

    func userDoc(_ uid: String) -> DocumentReference { usersCol.document(uid) }
    func usernameDoc(_ lower: String) -> DocumentReference { usernamesCol.document(lower) }
    func friendsCol(of uid: String) -> CollectionReference { userDoc(uid).collection("friends") }
    func friendDoc(of uid: String, friend friendUid: String) -> DocumentReference {
        friendsCol(of: uid).document(friendUid)
    }
}
