import SwiftUI

// MARK: - Rank Tier (Wood, Bronze, Silver, etc.)

enum RankTier: Int, CaseIterable {
    case wood = 0
    case bronze
    case silver
    case gold
    case platinum
    case diamond
    case titan
    case olympian

    var name: String {
        switch self {
        case .wood: "Wood"
        case .bronze: "Bronze"
        case .silver: "Silver"
        case .gold: "Gold"
        case .platinum: "Platinum"
        case .diamond: "Diamond"
        case .titan: "Titan"
        case .olympian: "Olympian"
        }
    }

    var icon: String {
        switch self {
        case .wood: "shield.fill"
        case .bronze: "shield.lefthalf.filled"
        case .silver: "star.fill"
        case .gold: "crown.fill"
        case .platinum: "bolt.shield.fill"
        case .diamond: "diamond.fill"
        case .titan: "flame.fill"
        case .olympian: "laurel.leading"
        }
    }

    /// Asset catalog image name for the custom rank badge.
    var imageName: String {
        switch self {
        case .wood: "wood_rank"
        case .bronze: "bronze_rank"
        case .silver: "silver_rank"
        case .gold: "gold_rank"
        case .platinum: "platinum_rank"
        case .diamond: "diamond_rank"
        case .titan: "titan_rank"
        case .olympian: "olympian_rank"
        }
    }

    var color: Color {
        switch self {
        case .wood: Color(hex: "8B6914")
        case .bronze: Color(hex: "CD7F32")
        case .silver: Color(hex: "C0C0C0")
        case .gold: Color(hex: "FFD700")
        case .platinum: Color(hex: "7BE0D6")
        case .diamond: Color(hex: "B9F2FF")
        case .titan: Color(hex: "FF4444")
        case .olympian: Color(hex: "E0B0FF")
        }
    }

    /// Number of sub-levels in this tier.
    var subLevels: Int { 5 }
}

// MARK: - Level Info (computed from totalXP)

struct LevelInfo: Equatable {
    let globalLevel: Int       // 1-based global level (1, 2, 3, ... 40)
    let tier: RankTier         // Wood, Bronze, etc.
    let subLevel: Int          // 1-5 within the tier
    let currentXP: Int         // XP within this level
    let xpRequired: Int        // XP needed for this level
    let totalXP: Int           // Total accumulated XP

    var displayName: String {
        "\(tier.name) \(romanNumeral(subLevel))"
    }

    var icon: String { tier.icon }
    var imageName: String { tier.imageName }
    var color: Color { tier.color }

    var progress: Double {
        guard xpRequired > 0 else { return 0 }
        return Double(currentXP) / Double(xpRequired)
    }

    private func romanNumeral(_ n: Int) -> String {
        switch n {
        case 1: "I"
        case 2: "II"
        case 3: "III"
        case 4: "IV"
        case 5: "V"
        default: "\(n)"
        }
    }
}

// MARK: - Level Thresholds

struct LevelSystem {
    /// XP thresholds for each global level (0-indexed).
    /// Level 1 (Wood I) needs xpForLevel[0] XP, Level 2 (Wood II) needs xpForLevel[1], etc.
    static let xpForLevel: [Int] = {
        var thresholds: [Int] = []
        for tier in RankTier.allCases {
            for sub in 0..<tier.subLevels {
                let levelIndex = tier.rawValue * 5 + sub
                let xp: Int
                switch levelIndex {
                // Wood I-V: gentle ramp
                case 0: xp = 100
                case 1: xp = 150
                case 2: xp = 200
                case 3: xp = 300
                case 4: xp = 400
                // Bronze I-V
                case 5: xp = 500
                case 6: xp = 650
                case 7: xp = 800
                case 8: xp = 1_000
                case 9: xp = 1_200
                // Silver I-V
                case 10: xp = 1_500
                case 11: xp = 1_800
                case 12: xp = 2_200
                case 13: xp = 2_600
                case 14: xp = 3_000
                // Gold I-V
                case 15: xp = 3_500
                case 16: xp = 4_000
                case 17: xp = 4_800
                case 18: xp = 5_500
                case 19: xp = 6_500
                // Platinum I-V
                case 20: xp = 7_500
                case 21: xp = 8_500
                case 22: xp = 10_000
                case 23: xp = 12_000
                case 24: xp = 14_000
                // Diamond I-V
                case 25: xp = 16_000
                case 26: xp = 19_000
                case 27: xp = 22_000
                case 28: xp = 26_000
                case 29: xp = 30_000
                // Titan I-V
                case 30: xp = 35_000
                case 31: xp = 40_000
                case 32: xp = 48_000
                case 33: xp = 56_000
                case 34: xp = 65_000
                // Olympian I-V
                case 35: xp = 75_000
                case 36: xp = 90_000
                case 37: xp = 110_000
                case 38: xp = 140_000
                case 39: xp = 180_000
                default: xp = 200_000
                }
                thresholds.append(xp)
            }
        }
        return thresholds
    }()

    /// Cumulative XP needed to START each level.
    static let cumulativeXP: [Int] = {
        var cumulative: [Int] = [0] // Level 1 starts at 0 cumulative XP
        for i in 0..<xpForLevel.count {
            cumulative.append(cumulative[i] + xpForLevel[i])
        }
        return cumulative
    }()

    /// Total number of levels.
    static var maxLevel: Int { xpForLevel.count }

    /// Get LevelInfo from total XP.
    static func levelInfo(for totalXP: Int) -> LevelInfo {
        // Find which level the player is at
        var globalLevel = 0 // 0-indexed
        for i in 0..<cumulativeXP.count - 1 {
            if totalXP >= cumulativeXP[i + 1] {
                globalLevel = i + 1
            } else {
                break
            }
        }

        // Cap at max level
        globalLevel = min(globalLevel, maxLevel - 1)

        let tierIndex = globalLevel / 5
        let subIndex = globalLevel % 5
        let tier = RankTier.allCases[min(tierIndex, RankTier.allCases.count - 1)]

        let xpIntoThisLevel = totalXP - cumulativeXP[globalLevel]
        let xpNeeded = xpForLevel[min(globalLevel, xpForLevel.count - 1)]

        return LevelInfo(
            globalLevel: globalLevel + 1, // 1-based
            tier: tier,
            subLevel: subIndex + 1,       // 1-based
            currentXP: min(xpIntoThisLevel, xpNeeded),
            xpRequired: xpNeeded,
            totalXP: totalXP
        )
    }

    /// Get all levels for roadmap display.
    static func allLevels(currentTotalXP: Int) -> [RoadmapLevel] {
        (0..<maxLevel).map { i in
            let tierIndex = i / 5
            let subIndex = i % 5
            let tier = RankTier.allCases[min(tierIndex, RankTier.allCases.count - 1)]
            let current = levelInfo(for: currentTotalXP)
            let isCompleted = currentTotalXP >= cumulativeXP[min(i + 1, cumulativeXP.count - 1)]
            let isCurrent = (i + 1) == current.globalLevel

            return RoadmapLevel(
                globalLevel: i + 1,
                tier: tier,
                subLevel: subIndex + 1,
                xpRequired: xpForLevel[i],
                cumulativeXPNeeded: cumulativeXP[i],
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                currentXPInLevel: isCurrent ? current.currentXP : 0
            )
        }
    }
}

// MARK: - Roadmap Level (for level list UI)

struct RoadmapLevel: Identifiable {
    var id: Int { globalLevel }
    let globalLevel: Int
    let tier: RankTier
    let subLevel: Int
    let xpRequired: Int
    let cumulativeXPNeeded: Int
    let isCompleted: Bool
    let isCurrent: Bool
    let currentXPInLevel: Int

    var displayName: String {
        "\(tier.name) \(romanNumeral(subLevel))"
    }

    private func romanNumeral(_ n: Int) -> String {
        switch n {
        case 1: "I"
        case 2: "II"
        case 3: "III"
        case 4: "IV"
        case 5: "V"
        default: "\(n)"
        }
    }
}
