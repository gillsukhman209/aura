import SwiftUI

enum AppTheme {
    // MARK: - Backgrounds (pure black base)
    static let bgPure = Color(hex: "050505")
    static let bgCard = Color(hex: "111111")
    static let bgCardBorder = Color(hex: "1E1E1E")
    static let bgTabBar = Color(hex: "050505")

    // MARK: - Galaxy / Atmosphere (muted, neutral)
    static let cloudWarm = Color(red: 0.12, green: 0.12, blue: 0.14)
    static let cloudCool = Color(red: 0.08, green: 0.08, blue: 0.10)
    static let cloudWisp = Color(red: 0.10, green: 0.10, blue: 0.12)

    // MARK: - Ring
    static let ringTrackDark = Color(hex: "040404")
    static let ringTrackShadow = Color(hex: "060606")
    static let ringTrackBody = Color(hex: "121212")
    static let ringTrackBodyAlt = Color(hex: "0A0A0A")
    static let ringBevel = Color(hex: "2A2A2A")
    static let ringGlow = Color(hex: "4090E0")
    static let ringGlowWide = Color(hex: "3878D0")
    static let ringGoldTip = Color(hex: "E8D430")

    // MARK: - Ring Arc Gradient Stops
    static let arcBlueDeep = Color(hex: "2058C0")
    static let arcBlue = Color(hex: "2E6CE0")
    static let arcBlueBright = Color(hex: "3A7EF0")
    static let arcBluePeak = Color(hex: "4890FF")
    static let arcBlueMid = Color(hex: "4A8CFF")
    static let arcBlueSoft1 = Color(hex: "5898FF")
    static let arcBlueSoft2 = Color(hex: "6AA4FF")
    static let arcFade = Color(hex: "88B4F0")
    static let arcTransition = Color(hex: "A8C0D8")
    static let arcGoldStart = Color(hex: "C0A848")
    static let arcGoldMid = Color(hex: "D8C038")
    static let arcGoldEnd = Color(hex: "E8D430")

    // MARK: - Text (neutral grays, no purple tint)
    static let textBright = Color(hex: "F0F0F0")
    static let textMuted = Color(hex: "888888")
    static let textDim = Color(hex: "666666")
    static let textGold = Color(hex: "DCCA58")
    static let textStat = Color(hex: "D0D0D0")
    static let textSubtle = Color(hex: "505050")

    // MARK: - Stat Icon Colors
    static let statGold = Color(hex: "C9A84C")
    static let statBlue = Color(hex: "4A88DD")
    static let statOrange = Color(hex: "E8652B")

    // MARK: - Progress Bars
    static let barGroove = Color(hex: "0C0C0C")
    static let barGrooveBorder = Color(hex: "1A1A1A")
    static let barFillStart = Color(hex: "1E4878")
    static let barFillMid1 = Color(hex: "2C6CB0")
    static let barFillMid2 = Color(hex: "3C88D0")
    static let barFillEnd = Color(hex: "50A0F0")
    static let barGlow = Color(hex: "4090E0")
    static let barHotEdge = Color(hex: "70B8FF")

    // MARK: - Tab Bar
    static let tabActive = Color(hex: "FFFFFF")
    static let tabInactive = Color(hex: "3A3A3A")
    static let tabGlow = Color(hex: "FFFFFF")
    static let tabSeparator = Color(hex: "1A1A1A")

    // MARK: - Accents
    static let accentGreen = Color(hex: "4ADE80")
    static let accentDanger = Color(hex: "FF3B30")
    static let accentOrange = Color(hex: "FF6B35")
    static let accentPurple = Color(hex: "7A5CFF")
    static let goldBright = Color(hex: "FFD700")
    static let gold = Color(hex: "C9A84C")

    // MARK: - Decorative
    static let dividerColor = Color(hex: "1A1A1A")
    static let headerDiamond = Color(hex: "333333")
    static let headerLine = Color(hex: "252525")

    // MARK: - Gradients
    static let goldGradient = LinearGradient(
        colors: [goldBright, gold],
        startPoint: .leading,
        endPoint: .trailing
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
