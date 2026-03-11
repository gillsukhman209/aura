import SwiftUI

struct GlowingButton: View {
    let title: String
    var style: ButtonStyle = .outlined
    let action: () -> Void
    @State private var glowing = false

    enum ButtonStyle {
        case outlined
        case filled
        case danger
    }

    private var buttonColor: Color {
        switch style {
        case .outlined, .filled: return AppTheme.tabActive
        case .danger: return AppTheme.accentDanger
        }
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .serif))
                .foregroundColor(.white)
                .tracking(4)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    Group {
                        switch style {
                        case .outlined:
                            RoundedRectangle(cornerRadius: 14)
                                .fill(buttonColor.opacity(0.06))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            buttonColor.opacity(glowing ? 0.7 : 0.3),
                                            lineWidth: 1
                                        )
                                )
                                .shadow(color: buttonColor.opacity(glowing ? 0.3 : 0.1), radius: glowing ? 12 : 6)
                        case .filled:
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [buttonColor, buttonColor.opacity(0.7)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: buttonColor.opacity(glowing ? 0.5 : 0.2), radius: glowing ? 12 : 6)
                        case .danger:
                            RoundedRectangle(cornerRadius: 14)
                                .fill(buttonColor.opacity(0.08))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            buttonColor.opacity(glowing ? 0.6 : 0.25),
                                            lineWidth: 1
                                        )
                                )
                                .shadow(color: buttonColor.opacity(glowing ? 0.25 : 0.08), radius: glowing ? 10 : 5)
                        }
                    }
                )
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowing = true
            }
        }
    }
}
