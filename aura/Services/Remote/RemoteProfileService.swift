import Foundation
import FirebaseFirestore

/// Mirrors the local `UserProfile` (plus weekly XP + week-reset logic) into Firestore.
final class RemoteProfileService {
    static let shared = RemoteProfileService()
    private init() {}

    private let fb = FirebaseService.shared

    /// Apply an XP + stat + streak delta to the remote user doc in a single transaction.
    /// Handles weekly rollover by comparing stored `weekResetKey` to the current week.
    func applyDelta(
        xpDelta: Int,
        stat: StatType?,
        statDelta: Int,
        currentStreak: Int?,
        longestStreak: Int?,
        lastCompletedDate: Date?
    ) {
        guard FirebaseService.enabled else { return }
        guard let uid = AuthService.shared.currentUID else { return }
        let userRef = fb.userDoc(uid)
        let nowKey = WeekKey.current()

        Task {
            do {
                _ = try await fb.db.runTransaction({ txn, errorPointer -> Any? in
                    do {
                        let snap = try txn.getDocument(userRef)
                        var data = snap.data() ?? [:]

                        let prevTotal = (data["totalXP"] as? Int) ?? 0
                        let newTotal = max(0, prevTotal + xpDelta)

                        let storedWeekKey = data["weekResetKey"] as? String
                        let prevWeekly = (data["weeklyXP"] as? Int) ?? 0
                        let weekly: Int
                        if storedWeekKey == nowKey {
                            weekly = max(0, prevWeekly + xpDelta)
                        } else {
                            weekly = max(0, xpDelta)
                        }

                        var stats = (data["stats"] as? [String: Int]) ?? [:]
                        if let stat, statDelta != 0 {
                            stats[stat.rawValue, default: 0] = max(0, (stats[stat.rawValue] ?? 0) + statDelta)
                        }

                        let info = LevelSystem.levelInfo(for: newTotal)

                        var update: [String: Any] = [
                            "totalXP": newTotal,
                            "weeklyXP": weekly,
                            "weekResetKey": nowKey,
                            "stats": stats,
                            "rankTier": info.tier.name,
                            "globalLevel": info.globalLevel,
                            "updatedAt": FieldValue.serverTimestamp()
                        ]
                        if let currentStreak { update["currentStreak"] = currentStreak }
                        if let longestStreak { update["longestStreak"] = longestStreak }
                        if let lastCompletedDate { update["lastCompletedDate"] = Timestamp(date: lastCompletedDate) }

                        txn.setData(update, forDocument: userRef, merge: true)
                        return nil
                    } catch {
                        errorPointer?.pointee = error as NSError
                        return nil
                    }
                })
            } catch {
                print("RemoteProfileService.applyDelta failed: \(error)")
            }
        }
    }

    /// Overwrite the remote user doc with the local profile's current state (debug seed / hard reset).
    /// Preserves `username` / `usernameLower` / `createdAt` / `weeklyXP` since those are owned by the remote record.
    func pushFullProfile(from profile: UserProfile) {
        guard FirebaseService.enabled else { return }
        guard let uid = AuthService.shared.currentUID else { return }
        var payload = migrationPayload(from: profile)
        payload["updatedAt"] = FieldValue.serverTimestamp()
        Task {
            do {
                try await fb.userDoc(uid).setData(payload, merge: true)
            } catch {
                print("RemoteProfileService.pushFullProfile failed: \(error)")
            }
        }
    }

    /// One-shot: write the local profile's full state to Firestore. Used during username claim / migration.
    func migrationPayload(from profile: UserProfile) -> [String: Any] {
        let info = LevelSystem.levelInfo(for: profile.totalXP)
        var payload: [String: Any] = [
            "totalXP": profile.totalXP,
            "weeklyXP": 0,
            "weekResetKey": WeekKey.current(),
            "currentStreak": profile.currentStreak,
            "longestStreak": profile.longestStreak,
            "stats": profile.stats,
            "rankTier": info.tier.name,
            "globalLevel": info.globalLevel
        ]
        if let last = profile.lastCompletedDate {
            payload["lastCompletedDate"] = Timestamp(date: last)
        }
        return payload
    }
}
