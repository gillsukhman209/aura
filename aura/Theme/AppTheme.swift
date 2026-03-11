import SwiftUI

enum AppTheme {
    // MARK: - Backgrounds (dark blue-purple base)
    static let bgPure = Color(hex: "08081A")
    static let bgCard = Color(hex: "10101E")
    static let bgCardBorder = Color(hex: "1E1E35")
    static let bgTabBar = Color(hex: "06060F")

    // MARK: - Galaxy / Atmosphere
    static let cloudWarm = Color(red: 0.18, green: 0.12, blue: 0.22)
    static let cloudCool = Color(red: 0.10, green: 0.10, blue: 0.20)
    static let cloudWisp = Color(red: 0.15, green: 0.10, blue: 0.25)

    // MARK: - Ring
    static let ringTrackDark = Color(hex: "04040C")
    static let ringTrackShadow = Color(hex: "06060E")
    static let ringTrackBody = Color(hex: "141420")
    static let ringTrackBodyAlt = Color(hex: "0C0C18")
    static let ringBevel = Color(hex: "2A2A40")
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

    // MARK: - Text
    static let textBright = Color(hex: "F4F4FF")
    static let textMuted = Color(hex: "A0A0BC")
    static let textDim = Color(hex: "8080A8")
    static let textGold = Color(hex: "DCCA58")
    static let textStat = Color(hex: "DCDCF0")
    static let textSubtle = Color(hex: "686888")

    // MARK: - Stat Icon Colors
    static let statGold = Color(hex: "C9A84C")
    static let statBlue = Color(hex: "4A88DD")
    static let statOrange = Color(hex: "E8652B")

    // MARK: - Progress Bars
    static let barGroove = Color(hex: "0C0C1A")
    static let barGrooveBorder = Color(hex: "181828")
    static let barFillStart = Color(hex: "1E4878")
    static let barFillMid1 = Color(hex: "2C6CB0")
    static let barFillMid2 = Color(hex: "3C88D0")
    static let barFillEnd = Color(hex: "50A0F0")
    static let barGlow = Color(hex: "4090E0")
    static let barHotEdge = Color(hex: "70B8FF")

    // MARK: - Tab Bar
    static let tabActive = Color(hex: "5090F0")
    static let tabInactive = Color(hex: "303048")
    static let tabGlow = Color(hex: "4080E0")
    static let tabSeparator = Color(hex: "1E1E35")

    // MARK: - Accents
    static let accentGreen = Color(hex: "4ADE80")
    static let accentDanger = Color(hex: "FF3B30")
    static let accentOrange = Color(hex: "FF6B35")
    static let accentPurple = Color(hex: "7A5CFF")
    static let goldBright = Color(hex: "FFD700")
    static let gold = Color(hex: "C9A84C")

    // MARK: - Decorative
    static let dividerColor = Color(hex: "1C1C32")
    static let headerDiamond = Color(hex: "3A3A55")
    static let headerLine = Color(hex: "2A2A45")

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
