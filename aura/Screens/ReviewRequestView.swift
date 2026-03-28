import SwiftUI
import StoreKit

struct ReviewRequestView: View {
    @Environment(\.requestReview) private var requestReview
    @Binding var isPresented: Bool

    @State private var heartScale: CGFloat = 0.5
    @State private var heartOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var messageOpacity: Double = 0
    @State private var buttonsOpacity: Double = 0

    var body: some View {
        ZStack {
            AppTheme.bgPure.ignoresSafeArea()
            StarfieldBackground(starCount: 100)
                .opacity(0.3)

            VStack(spacing: 0) {
                Spacer()

                // Heart icon with glow
                ZStack {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 70))
                        .foregroundColor(AppTheme.accentPurple.opacity(0.3))
                        .blur(radius: 20)

                    Image(systemName: "heart.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [AppTheme.accentPurple, Color(hex: "FF6B9D")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: AppTheme.accentPurple.opacity(0.4), radius: 12)
                }
                .scaleEffect(heartScale)
                .opacity(heartOpacity)

                Spacer().frame(height: 32)

                // Title
                Text("You just did something\nmost people won't.")
                    .font(.system(size: 26, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(textOpacity)

                Spacer().frame(height: 20)

                // Emotional message
                VStack(spacing: 16) {
                    Text("We built Aura because we believe everyone deserves a second chance at becoming who they're meant to be.")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(AppTheme.textMuted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)

                    Text("We're a tiny team. No big funding, no ads.\nJust two people trying to help.")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(AppTheme.textMuted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)

                    Text("A quick review helps others find us\nand start their journey too.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                }
                .padding(.horizontal, 32)
                .opacity(messageOpacity)

                Spacer()

                // Buttons
                VStack(spacing: 12) {
                    Button {
                        isPresented = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            requestReview()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 14))
                            Text("I'll leave a review")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(AppTheme.bgPure)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(.white)
                        )
                    }

                    Button {
                        isPresented = false
                    } label: {
                        Text("Maybe later")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(AppTheme.textMuted)
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .opacity(buttonsOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                heartScale = 1.0
                heartOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.7).delay(0.5)) {
                textOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.7).delay(0.9)) {
                messageOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.7).delay(1.3)) {
                buttonsOpacity = 1
            }
        }
    }
}
