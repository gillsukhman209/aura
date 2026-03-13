import SwiftUI

struct ResetView: View {
    @State private var titleOpacity: Double = 0
    @State private var buttonVisible = false
    @State private var silhouetteOpacity: Double = 0

    var body: some View {
        ZStack {
            Color(hex: "050505").ignoresSafeArea()

            ZStack {
                Image(systemName: "figure.martial.arts")
                    .font(.system(size: 250, weight: .ultraLight))
                    .foregroundColor(Color(hex: "1A1A1A"))
                    .offset(x: 60, y: -50)
                    .opacity(silhouetteOpacity)
            }

            StarfieldBackground(starCount: 60)
                .opacity(0.15)

            VStack(spacing: 0) {
                Spacer()
                Spacer()

                Text("RESET")
                    .font(.system(size: 48, weight: .black))
                    .foregroundColor(.white)
                    .tracking(12)
                    .opacity(titleOpacity)

                Text("For the bold.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(hex: "555555"))
                    .padding(.top, 8)
                    .opacity(titleOpacity)

                Spacer()

                GlowingButton(title: "START OVER", style: .danger) {}
                    .padding(.horizontal, 40)
                    .opacity(buttonVisible ? 1 : 0)

                Spacer().frame(height: 80)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) { titleOpacity = 1; silhouetteOpacity = 1 }
            withAnimation(.easeOut(duration: 0.8).delay(0.6)) { buttonVisible = true }
        }
    }
}
