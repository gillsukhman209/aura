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
        case .outlined, .filled: return .white
        case .danger: return AppTheme.accentDanger
        }
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .tracking(4)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    Group {
                        switch style {
                        case .outlined:
                            RoundedRectangle(cornerRadius: 14)
                                .fill(buttonColor.opacity(0.04))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            buttonColor.opacity(glowing ? 0.5 : 0.2),
                                            lineWidth: 1
                                        )
                                )
                                .shadow(color: buttonColor.opacity(glowing ? 0.15 : 0.05), radius: glowing ? 12 : 6)
                        case .filled:
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [buttonColor.opacity(0.2), buttonColor.opacity(0.1)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: buttonColor.opacity(glowing ? 0.3 : 0.1), radius: glowing ? 12 : 6)
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
