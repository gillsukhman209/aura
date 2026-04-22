import Foundation
import FirebaseFirestore
import Observation

@Observable
final class FriendService {
    static let shared = FriendService()
    private init() {}

    private let fb = FirebaseService.shared

    // Observed state for UI.
    private(set) var friendUIDs: Set<String> = []
    private(set) var friendUsernames: [String: String] = [:]
    private(set) var leaderboard: [RemoteUser] = []
    private(set) var incomingRequests: [FriendRequest] = []
    private(set) var outgoingRequests: [FriendRequest] = []

    private var friendsListener: ListenerRegistration?
    private var incomingListener: ListenerRegistration?
    private var outgoingListener: ListenerRegistration?
    private var leaderboardListeners: [String: ListenerRegistration] = [:]

    // MARK: - Lifecycle

    func start(forUID uid: String) {
        guard FirebaseService.enabled else {
            seedMockLeaderboard()
            return
        }
        stop()
        attachFriendsListener(uid: uid)
        attachRequestsListeners(uid: uid)
    }

    /// Populate the leaderboard with plausible fake friends so the Friends tab can be screenshotted
    /// while Firebase is disabled. Values are randomised per call.
    private func seedMockLeaderboard() {
        let names = ["alexis", "mike_t", "sarah_k", "devon", "priya", "jordan99"]
        let nowKey = WeekKey.current()
        let mocks: [RemoteUser] = names.shuffled().prefix(5).map { name in
            let total = Int.random(in: 1200...8400)
            return RemoteUser(
                uid: "mock-\(name)",
                username: name,
                usernameLower: name,
                totalXP: total,
                weeklyXP: Int.random(in: 80...520),
                weekResetKey: nowKey,
                currentStreak: Int.random(in: 2...28),
                longestStreak: Int.random(in: 14...60),
                createdAt: Date()
            )
        }
        Task { @MainActor in
            self.friendUIDs = Set(mocks.map { $0.uid })
            self.friendUsernames = Dictionary(uniqueKeysWithValues: mocks.map { ($0.uid, $0.username) })
            self.leaderboard = mocks.sorted { $0.weeklyXP > $1.weeklyXP }
            self.incomingRequests = []
            self.outgoingRequests = []
        }
    }

    func stop() {
        friendsListener?.remove(); friendsListener = nil
        incomingListener?.remove(); incomingListener = nil
        outgoingListener?.remove(); outgoingListener = nil
        leaderboardListeners.values.forEach { $0.remove() }
        leaderboardListeners = [:]
        friendUIDs = []
        friendUsernames = [:]
        leaderboard = []
        incomingRequests = []
        outgoingRequests = []
    }

    // MARK: - Search

    func search(prefix raw: String) async throws -> [RemoteUser] {
        guard FirebaseService.enabled else { return [] }
        let q = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return [] }
        let end = q + "\u{f8ff}"
        let snap = try await fb.usersCol
            .whereField("usernameLower", isGreaterThanOrEqualTo: q)
            .whereField("usernameLower", isLessThan: end)
            .limit(to: 20)
            .getDocuments()
        return snap.documents.compactMap { Self.decodeUser(from: $0) }
    }

    func relationshipState(for uid: String) -> RelationshipState {
        guard let me = AuthService.shared.currentUID else { return .none }
        if uid == me { return .none }
        if friendUIDs.contains(uid) { return .alreadyFriends }
        let pairID = FriendRequest.deterministicID(a: me, b: uid)
        if outgoingRequests.contains(where: { $0.id == pairID }) { return .requestSent }
        if incomingRequests.contains(where: { $0.id == pairID }) { return .requestReceived }
        return .none
    }

    // MARK: - Requests

    func sendRequest(to target: RemoteUser) async throws {
        guard FirebaseService.enabled else { return }
        guard let me = AuthService.shared.currentUID else { throw AuthError.notSignedIn }
        guard let myUsername = AuthService.shared.currentUsername else { throw AuthError.notSignedIn }
        let pairID = FriendRequest.deterministicID(a: me, b: target.uid)
        let ref = fb.friendRequestsCol.document(pairID)
        try await ref.setData([
            "fromUid": me,
            "toUid": target.uid,
            "fromUsername": myUsername,
            "status": "pending",
            "createdAt": FieldValue.serverTimestamp()
        ])
    }

    func decline(_ request: FriendRequest) async throws {
        guard FirebaseService.enabled else { return }
        try await fb.friendRequestsCol.document(request.id).delete()
    }

    func accept(_ request: FriendRequest) async throws {
        guard FirebaseService.enabled else { return }
        guard let me = AuthService.shared.currentUID, me == request.toUid else {
            throw AuthError.notSignedIn
        }
        guard let myUsername = AuthService.shared.currentUsername else { throw AuthError.notSignedIn }

        let fromUserSnap = try await fb.userDoc(request.fromUid).getDocument()
        let fromUsername = (fromUserSnap.data()?["username"] as? String) ?? request.fromUsername

        let myFriendRef = fb.friendDoc(of: me, friend: request.fromUid)
        let theirFriendRef = fb.friendDoc(of: request.fromUid, friend: me)
        let requestRef = fb.friendRequestsCol.document(request.id)
        let now = FieldValue.serverTimestamp()

        let batch = fb.db.batch()
        batch.setData(["friendUid": request.fromUid, "friendUsername": fromUsername, "since": now], forDocument: myFriendRef)
        batch.setData(["friendUid": me, "friendUsername": myUsername, "since": now], forDocument: theirFriendRef)
        batch.deleteDocument(requestRef)
        try await batch.commit()
    }

    func remove(friendUID: String) async throws {
        guard FirebaseService.enabled else { return }
        guard let me = AuthService.shared.currentUID else { throw AuthError.notSignedIn }
        let batch = fb.db.batch()
        batch.deleteDocument(fb.friendDoc(of: me, friend: friendUID))
        batch.deleteDocument(fb.friendDoc(of: friendUID, friend: me))
        try await batch.commit()
    }

    // MARK: - Listeners

    private func attachFriendsListener(uid: String) {
        friendsListener = fb.friendsCol(of: uid).addSnapshotListener { [weak self] snap, _ in
            guard let self, let snap else { return }
            var uids: Set<String> = []
            var usernames: [String: String] = [:]
            for doc in snap.documents {
                let data = doc.data()
                if let fuid = data["friendUid"] as? String {
                    uids.insert(fuid)
                    usernames[fuid] = (data["friendUsername"] as? String) ?? ""
                }
            }
            Task { @MainActor in
                self.friendUIDs = uids
                self.friendUsernames = usernames
                self.refreshLeaderboardListeners(uids: uids)
            }
        }
    }

    private func attachRequestsListeners(uid: String) {
        incomingListener = fb.friendRequestsCol
            .whereField("toUid", isEqualTo: uid)
            .addSnapshotListener { [weak self] snap, _ in
                guard let self, let snap else { return }
                let items = snap.documents.compactMap { Self.decodeRequest(from: $0) }
                Task { @MainActor in self.incomingRequests = items }
            }

        outgoingListener = fb.friendRequestsCol
            .whereField("fromUid", isEqualTo: uid)
            .addSnapshotListener { [weak self] snap, _ in
                guard let self, let snap else { return }
                let items = snap.documents.compactMap { Self.decodeRequest(from: $0) }
                Task { @MainActor in self.outgoingRequests = items }
            }
    }

    @MainActor
    private func refreshLeaderboardListeners(uids: Set<String>) {
        // Remove listeners for friends that no longer exist.
        for (uid, listener) in leaderboardListeners where !uids.contains(uid) {
            listener.remove()
            leaderboardListeners.removeValue(forKey: uid)
            leaderboard.removeAll { $0.uid == uid }
        }
        // Add listeners for new friends.
        for uid in uids where leaderboardListeners[uid] == nil {
            let listener = fb.userDoc(uid).addSnapshotListener { [weak self] snap, _ in
                guard let self, let snap, snap.exists, let user = Self.decodeUser(from: snap) else { return }
                Task { @MainActor in
                    if let idx = self.leaderboard.firstIndex(where: { $0.uid == uid }) {
                        self.leaderboard[idx] = user
                    } else {
                        self.leaderboard.append(user)
                    }
                    self.leaderboard.sort { lhs, rhs in
                        let nowKey = WeekKey.current()
                        let lw = lhs.effectiveWeeklyXP(nowKey: nowKey)
                        let rw = rhs.effectiveWeeklyXP(nowKey: nowKey)
                        if lw != rw { return lw > rw }
                        return lhs.totalXP > rhs.totalXP
                    }
                }
            }
            leaderboardListeners[uid] = listener
        }
    }

    // MARK: - Decoding

    static func decodeUser(from doc: DocumentSnapshot) -> RemoteUser? {
        guard let data = doc.data() else { return nil }
        guard let username = data["username"] as? String,
              let usernameLower = data["usernameLower"] as? String
        else { return nil }
        let created: Date
        if let ts = data["createdAt"] as? Timestamp {
            created = ts.dateValue()
        } else {
            created = Date()
        }
        return RemoteUser(
            uid: doc.documentID,
            username: username,
            usernameLower: usernameLower,
            totalXP: (data["totalXP"] as? Int) ?? 0,
            weeklyXP: (data["weeklyXP"] as? Int) ?? 0,
            weekResetKey: (data["weekResetKey"] as? String) ?? "",
            currentStreak: (data["currentStreak"] as? Int) ?? 0,
            longestStreak: (data["longestStreak"] as? Int) ?? 0,
            createdAt: created
        )
    }

    private static func decodeRequest(from doc: DocumentSnapshot) -> FriendRequest? {
        guard let data = doc.data() else { return nil }
        guard let fromUid = data["fromUid"] as? String,
              let toUid = data["toUid"] as? String
        else { return nil }
        let created: Date
        if let ts = data["createdAt"] as? Timestamp {
            created = ts.dateValue()
        } else {
            created = Date()
        }
        return FriendRequest(
            id: doc.documentID,
            fromUid: fromUid,
            toUid: toUid,
            fromUsername: (data["fromUsername"] as? String) ?? "",
            createdAt: created
        )
    }

    /// Fetch a single remote user (used by FriendProfileSheet for non-friends / fresh reads).
    func fetchUser(uid: String) async throws -> RemoteUser? {
        guard FirebaseService.enabled else { return nil }
        let snap = try await fb.userDoc(uid).getDocument()
        return Self.decodeUser(from: snap)
    }
}
