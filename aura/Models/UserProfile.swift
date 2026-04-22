import Foundation
import SwiftData

@Model
final class UserProfile {
    // MARK: - Identity

    @Attribute(.unique) var id: UUID

    /// Firebase Anonymous Auth UID, once claimed.
    var remoteUID: String?

    /// Chosen username, once claimed (mirrors Firestore `users/{uid}.username`).
    var username: String?

    // MARK: - XP & Leveling

    var totalXP: Int

    // MARK: - Streak

    var currentStreak: Int
    var longestStreak: Int

    /// The last calendar day where all required habits were completed.
    var lastCompletedDate: Date?

    // MARK: - Stats (stored as JSON dictionary)

    var statsData: Data

    // MARK: - Meta

    var createdAt: Date

    // MARK: - Computed (uses new LevelSystem)

    var levelInfo: LevelInfo { LevelSystem.levelInfo(for: totalXP) }

    var level: Int { levelInfo.globalLevel }

    var currentLevelXP: Int { levelInfo.currentXP }

    var xpForCurrentLevel: Int { levelInfo.xpRequired }

    var levelProgress: Double { levelInfo.progress }

    var stats: [String: Int] {
        get {
            (try? JSONDecoder().decode([String: Int].self, from: statsData)) ?? Self.defaultStatsDict
        }
        set {
            statsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }

    // MARK: - Init

    init() {
        self.id = UUID()
        self.remoteUID = nil
        self.username = nil
        self.totalXP = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.lastCompletedDate = nil
        self.createdAt = Date()
        self.statsData = (try? JSONEncoder().encode(Self.defaultStatsDict)) ?? Data()
    }

    // MARK: - Stat Accessors

    func statValue(for stat: StatType) -> Int {
        stats[stat.rawValue] ?? 0
    }

    func addStatXP(_ amount: Int, to stat: StatType) {
        var current = stats
        current[stat.rawValue, default: 0] += amount
        stats = current
    }

    // MARK: - XP

    func addXP(_ amount: Int) {
        totalXP += amount
    }

    func penalizeXP(_ amount: Int) {
        totalXP = max(0, totalXP - amount)
    }

    // MARK: - Streak

    func incrementStreak() {
        currentStreak += 1
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
    }

    func resetStreak() {
        currentStreak = 0
    }

    // MARK: - Defaults

    static let defaultStatsDict: [String: Int] = {
        var dict = [String: Int]()
        for stat in StatType.allCases {
            dict[stat.rawValue] = 0
        }
        return dict
    }()
}
