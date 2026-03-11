import SwiftUI

struct CharacterStat: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let value: Int
    let maxValue: Int
    let icon: String
    let color: Color
}

struct Quest: Identifiable {
    let id = UUID()
    let title: String
    let xpReward: Int
    let statType: String
    var isCompleted: Bool
    let icon: String
}

struct TrainingCategory: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let icon: String
    let color: Color
}

struct GameRank: Identifiable {
    let id = UUID()
    let name: String
    let tier: String
    let icon: String
    let color: Color
    let xpRequired: Int
    let isUnlocked: Bool
    let isCurrent: Bool
}

struct WeeklyStat: Identifiable {
    let id = UUID()
    let name: String
    let xpGained: Int
    let icon: String
    let color: Color
}

enum MockData {
    static let level = 7
    static let currentXP = 1420
    static let maxXP = 2000
    static let currentStreak = 12
    static let consistencyScore = 74

    static let stats: [CharacterStat] = [
        CharacterStat(name: "Strength", subtitle: "RANK", value: 68, maxValue: 100, icon: "figure.strengthtraining.traditional", color: AppTheme.statGold),
        CharacterStat(name: "Focus", subtitle: "RANK", value: 59, maxValue: 100, icon: "eye.fill", color: AppTheme.statBlue),
        CharacterStat(name: "Discipline", subtitle: "RANK", value: 74, maxValue: 100, icon: "flame.fill", color: AppTheme.statOrange),
        CharacterStat(name: "Knowledge", subtitle: "RANK", value: 72, maxValue: 100, icon: "book.fill", color: AppTheme.statGold),
        CharacterStat(name: "Energy", subtitle: "RANK", value: 58, maxValue: 100, icon: "bolt.fill", color: AppTheme.statBlue),
    ]

    static let dailyQuests: [Quest] = [
        Quest(title: "Run 2 miles", xpReward: 20, statType: "Strength", isCompleted: true, icon: "figure.run"),
        Quest(title: "Read 20 pages", xpReward: 15, statType: "Knowledge", isCompleted: true, icon: "book.fill"),
        Quest(title: "Deep Work (60 min)", xpReward: 25, statType: "Focus", isCompleted: true, icon: "brain.head.profile"),
        Quest(title: "Meditation (10 min)", xpReward: 10, statType: "Mindset", isCompleted: true, icon: "sparkles"),
    ]

    static let trainingCategories: [TrainingCategory] = [
        TrainingCategory(name: "Strength Training", subtitle: "Physical power & endurance", icon: "figure.strengthtraining.traditional", color: AppTheme.accentDanger),
        TrainingCategory(name: "Focus Training", subtitle: "Concentration & deep work", icon: "eye.fill", color: AppTheme.statBlue),
        TrainingCategory(name: "Mind Training", subtitle: "Mental resilience & clarity", icon: "brain.head.profile", color: AppTheme.accentPurple),
        TrainingCategory(name: "Knowledge Training", subtitle: "Learning & wisdom", icon: "book.fill", color: AppTheme.goldBright),
    ]

    static let ranks: [GameRank] = [
        GameRank(name: "Unranked", tier: "", icon: "circle.dashed", color: Color(hex: "555555"), xpRequired: 0, isUnlocked: true, isCurrent: false),
        GameRank(name: "Iron", tier: "", icon: "shield.fill", color: Color(hex: "8A8A8A"), xpRequired: 300, isUnlocked: true, isCurrent: false),
        GameRank(name: "Bronze", tier: "III", icon: "shield.lefthalf.filled", color: Color(hex: "CD7F32"), xpRequired: 210, isUnlocked: true, isCurrent: true),
        GameRank(name: "Silver", tier: "", icon: "star.fill", color: Color(hex: "C0C0C0"), xpRequired: 600, isUnlocked: false, isCurrent: false),
        GameRank(name: "Gold", tier: "", icon: "crown.fill", color: AppTheme.goldBright, xpRequired: 900, isUnlocked: false, isCurrent: false),
        GameRank(name: "Diamond", tier: "", icon: "diamond.fill", color: Color(hex: "B9F2FF"), xpRequired: 1000, isUnlocked: false, isCurrent: false),
    ]

    static let weeklyProgress: [WeeklyStat] = [
        WeeklyStat(name: "Strength", xpGained: 135, icon: "figure.strengthtraining.traditional", color: AppTheme.statGold),
        WeeklyStat(name: "Focus", xpGained: 85, icon: "eye.fill", color: AppTheme.statBlue),
        WeeklyStat(name: "Knowledge", xpGained: 70, icon: "book.fill", color: AppTheme.goldBright),
        WeeklyStat(name: "Discipline", xpGained: 120, icon: "flame.fill", color: AppTheme.accentOrange),
    ]
}
