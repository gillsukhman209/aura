import SwiftUI

/// PreferenceKey that collects on-screen rects for each tutorial step.
struct TutorialAnchorKey: PreferenceKey {
    static let defaultValue: [TutorialCoordinator.Step: Anchor<CGRect>] = [:]

    static func reduce(
        value: inout [TutorialCoordinator.Step: Anchor<CGRect>],
        nextValue: () -> [TutorialCoordinator.Step: Anchor<CGRect>]
    ) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

extension View {
    /// Tag this view as the target for a specific tutorial step.
    func tutorialAnchor(_ step: TutorialCoordinator.Step) -> some View {
        anchorPreference(key: TutorialAnchorKey.self, value: .bounds) { anchor in
            [step: anchor]
        }
    }

    /// Draws the active tutorial highlight + coaching card on top of the view hierarchy.
    /// Attach at the root of each screen that participates in the tutorial.
    func tutorialOverlay() -> some View {
        overlayPreferenceValue(TutorialAnchorKey.self) { anchors in
            GeometryReader { proxy in
                TutorialOverlayView(anchors: anchors, proxy: proxy)
            }
            .ignoresSafeArea()
        }
    }
}

struct TutorialOverlayView: View {
    let anchors: [TutorialCoordinator.Step: Anchor<CGRect>]
    let proxy: GeometryProxy

    private var tutorial = TutorialCoordinator.shared
    @State private var pulse = false

    init(anchors: [TutorialCoordinator.Step: Anchor<CGRect>], proxy: GeometryProxy) {
        self.anchors = anchors
        self.proxy = proxy
    }

    var body: some View {
        if tutorial.isActive, let anchor = anchors[tutorial.currentStep] {
            let rect = proxy[anchor]
            content(rect: rect)
        }
    }

    private func content(rect: CGRect) -> some View {
        let padded = rect.insetBy(dx: -10, dy: -10)
        let usedCorner: CGFloat = min(max(12, min(padded.height, padded.width) / 2), 24)
        let screen = CGRect(origin: .zero, size: proxy.size)

        // Four hit-blocker rectangles framing the cutout. Taps inside the cutout
        // pass through to the highlighted UI element underneath.
        let topHeight    = max(0, padded.minY)
        let bottomHeight = max(0, proxy.size.height - padded.maxY)
        let leftWidth    = max(0, padded.minX)
        let rightWidth   = max(0, proxy.size.width - padded.maxX)

        return ZStack {
            // Purely visual: dim background with rounded cutout. Not hit-testable.
            Path { path in
                path.addRect(screen)
                path.addRoundedRect(in: padded, cornerSize: CGSize(width: usedCorner, height: usedCorner))
            }
            .fill(Color.black.opacity(0.82), style: FillStyle(eoFill: true))
            .allowsHitTesting(false)

            // Hit-blockers: transparent but tappable, so non-cutout areas eat taps.
            Color.black.opacity(0.0001)
                .frame(width: proxy.size.width, height: topHeight)
                .position(x: proxy.size.width / 2, y: topHeight / 2)
            Color.black.opacity(0.0001)
                .frame(width: proxy.size.width, height: bottomHeight)
                .position(x: proxy.size.width / 2, y: padded.maxY + bottomHeight / 2)
            Color.black.opacity(0.0001)
                .frame(width: leftWidth, height: padded.height)
                .position(x: leftWidth / 2, y: padded.midY)
            Color.black.opacity(0.0001)
                .frame(width: rightWidth, height: padded.height)
                .position(x: padded.maxX + rightWidth / 2, y: padded.midY)

            // Pulse ring around the target.
            RoundedRectangle(cornerRadius: usedCorner)
                .stroke(Color.white.opacity(0.85), lineWidth: 2)
                .frame(width: padded.width, height: padded.height)
                .scaleEffect(pulse ? 1.04 : 1.0)
                .opacity(pulse ? 0.55 : 1.0)
                .position(x: padded.midX, y: padded.midY)
                .allowsHitTesting(false)

            card(targetRect: rect)
        }
        .transition(.opacity)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }

    private func card(targetRect: CGRect) -> some View {
        let step = tutorial.currentStep
        let cardWidth = min(proxy.size.width - 32, 360)
        let estimatedCardHeight: CGFloat = 150
        let gap: CGFloat = 14
        let safeTop: CGFloat = 70     // leave room for status bar / nav bar
        let safeBottom: CGFloat = 40  // leave room for home indicator

        let padded = targetRect.insetBy(dx: -10, dy: -10)
        let spaceBelow = proxy.size.height - padded.maxY - safeBottom
        let spaceAbove = padded.minY - safeTop
        let placeBelow = spaceBelow >= estimatedCardHeight + gap || spaceBelow >= spaceAbove

        let cardCenterY: CGFloat
        if placeBelow {
            cardCenterY = padded.maxY + gap + estimatedCardHeight / 2
        } else {
            cardCenterY = padded.minY - gap - estimatedCardHeight / 2
        }

        return VStack(alignment: .leading, spacing: 10) {
            Text(step.title.uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(3)
                .foregroundColor(AppTheme.gold)

            Text(step.body)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "D0D0D0"))
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(6)

            HStack {
                Button {
                    tutorial.skip()
                } label: {
                    Text("Skip tour")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.textMuted)
                        .padding(.vertical, 6)
                }

                Spacer()

                stepIndicator

                Spacer()

                if !step.requiresUserAction {
                    Button {
                        tutorial.advance()
                    } label: {
                        Text("NEXT")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(2)
                            .foregroundColor(.black)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.white))
                    }
                } else {
                    Text("TAP IT")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(2)
                        .foregroundColor(AppTheme.gold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            Capsule().stroke(AppTheme.gold.opacity(0.5), lineWidth: 1)
                        )
                }
            }
            .padding(.top, 6)
        }
        .padding(16)
        .frame(width: cardWidth)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppTheme.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.35), radius: 18, y: 6)
        )
        .position(x: proxy.size.width / 2, y: cardCenterY)
    }

    private var stepIndicator: some View {
        HStack(spacing: 4) {
            ForEach(TutorialCoordinator.Step.allCases, id: \.rawValue) { s in
                Circle()
                    .fill(s == tutorial.currentStep ? Color.white : Color.white.opacity(0.2))
                    .frame(width: 5, height: 5)
            }
        }
    }
}

