import Foundation

struct RemoteUser: Identifiable, Hashable {
    let uid: String
    let username: String
    let usernameLower: String
    let totalXP: Int
    let weeklyXP: Int
    let weekResetKey: String
    let currentStreak: Int
    let longestStreak: Int
    let createdAt: Date

    var id: String { uid }

    /// Returns effective weekly XP given the current week key — stale keys mean zero.
    func effectiveWeeklyXP(nowKey: String) -> Int {
        weekResetKey == nowKey ? weeklyXP : 0
    }
}

struct FriendRequest: Identifiable, Hashable {
    let id: String        // deterministic: "${min(a,b)}_${max(a,b)}"
    let fromUid: String
    let toUid: String
    let fromUsername: String
    let createdAt: Date

    static func deterministicID(a: String, b: String) -> String {
        let pair = [a, b].sorted()
        return "\(pair[0])_\(pair[1])"
    }
}

enum RelationshipState {
    case none
    case alreadyFriends
    case requestSent
    case requestReceived
}
