import Foundation
import SwiftData

@Model
final class UserProfile {
    // MARK: - Identity

    @Attribute(.unique) var id: UUID

    // MARK: - XP & Leveling

    var totalXP: Int
    var xpPerLevel: Int

    // MARK: - Streak

    var currentStreak: Int
    var longestStreak: Int

    /// The last calendar day where all required habits were completed.
    var lastCompletedDate: Date?

    // MARK: - Stats (stored as JSON dictionary)

    var statsData: Data

    // MARK: - Meta

    var createdAt: Date

    // MARK: - Computed

    var level: Int { totalXP / xpPerLevel }

    var currentLevelXP: Int { totalXP % xpPerLevel }

    var xpToNextLevel: Int { xpPerLevel }

    var levelProgress: Double {
        Double(currentLevelXP) / Double(xpPerLevel)
    }

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
        self.totalXP = 0
        self.xpPerLevel = 100
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

// MARK: - Rank

extension UserProfile {
    var rank: AuraRank {
        AuraRank.forLevel(level)
    }
}

// MARK: - Aura Rank

struct AuraRank {
    let name: String
    let tier: String
    let icon: String
    let color: String
    let minLevel: Int

    static let ranks: [AuraRank] = [
        AuraRank(name: "Unranked", tier: "", icon: "circle.dashed", color: "555555", minLevel: 0),
        AuraRank(name: "Iron", tier: "", icon: "shield.fill", color: "8A8A8A", minLevel: 3),
        AuraRank(name: "Bronze", tier: "III", icon: "shield.lefthalf.filled", color: "CD7F32", minLevel: 5),
        AuraRank(name: "Silver", tier: "", icon: "star.fill", color: "C0C0C0", minLevel: 10),
        AuraRank(name: "Gold", tier: "", icon: "crown.fill", color: "FFD700", minLevel: 20),
        AuraRank(name: "Diamond", tier: "", icon: "diamond.fill", color: "B9F2FF", minLevel: 35),
    ]

    static func forLevel(_ level: Int) -> AuraRank {
        ranks.last { $0.minLevel <= level } ?? ranks[0]
    }
}
