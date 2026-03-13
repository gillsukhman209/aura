import SwiftUI

struct HabitCard: View {
    let habit: Habit
    @Environment(HabitManager.self) private var manager
    @State private var showCheck = false
    @State private var showNumericInput = false
    @State private var numericText = ""
    @State private var showDetail = false
    @State private var showAPFloat = false
    @State private var apFloatOffset: CGFloat = 0
    @State private var apFloatOpacity: Double = 0

    private var hasBuildOrNumericCompletion: Bool {
        guard habit.type != .quit else { return false }
        return habit.isCompleted(on: appNow())
    }

    private var hasRelapsedToday: Bool {
        guard habit.type == .quit else { return false }
        return habit.log(for: appNow())?.status == .relapsed
    }

    private func triggerAPFloat() {
        apFloatOffset = 0
        apFloatOpacity = 1
        showAPFloat = true
        withAnimation(.easeOut(duration: 1.2)) {
            apFloatOffset = -50
        }
        withAnimation(.easeOut(duration: 1.2).delay(0.4)) {
            apFloatOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            showAPFloat = false
        }
    }

    private var isCompleted: Bool {
        if habit.type == .quit { return !hasRelapsedToday }
        return hasBuildOrNumericCompletion
    }

    /// The stat's color used as a subtle accent
    private var accent: Color { habit.stat.color }

    var body: some View {
        HStack(spacing: 12) {
            // ── Icon with colored tint ──
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(accent.opacity(0.08))
                    .frame(width: 50, height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(accent.opacity(0.12), lineWidth: 0.5)
                    )

                Image(systemName: habit.icon)
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundColor(accent.opacity(0.9))
            }

            // ── Text ──
            VStack(alignment: .leading, spacing: 3) {
                Text(habit.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)

                HStack(spacing: 4) {
                    Text("+\(habit.baseXP)")
                        .font(.system(size: 11, weight: .heavy))
                        .foregroundColor(accent.opacity(0.5))
                    Text(habit.stat.label.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundColor(Color(hex: "4A4A4A"))
                }

                if habit.type == .numeric, let target = habit.targetValue {
                    let current = habit.log(for: appNow())?.value ?? 0
                    let unit = habit.unit ?? ""
                    Text("\(String(format: "%.1f", current))/\(String(format: "%.0f", target)) \(unit)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "4A4A4A"))
                }

                if habit.type == .quit {
                    Text(hasRelapsedToday ? "RELAPSED" : "LOCKED IN")
                        .font(.system(size: 10, weight: .heavy))
                        .tracking(1)
                        .foregroundColor(hasRelapsedToday ? Color(hex: "FF3B30") : Color(hex: "4ADE80"))
                }
            }

            Spacer()

            completionIndicator
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "141414"), Color(hex: "0E0E0E")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            LinearGradient(
                                colors: [accent.opacity(0.10), Color.white.opacity(0.04)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                )
        )
        .overlay(alignment: .trailing) {
            if showAPFloat {
                Text("+\(habit.baseXP)")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(accent)
                    .shadow(color: accent.opacity(0.4), radius: 8)
                    .offset(y: apFloatOffset)
                    .opacity(apFloatOpacity)
                    .allowsHitTesting(false)
                    .padding(.trailing, 16)
            }
        }
        .onTapGesture {
            showDetail = true
        }
        .sheet(isPresented: $showDetail) {
            HabitDetailView(habit: habit)
        }
        .alert("Log \(habit.unit ?? "value")", isPresented: $showNumericInput) {
            TextField("Amount", text: $numericText)
                .keyboardType(.decimalPad)
            Button("Add") {
                if let val = Double(numericText), val > 0 {
                    let wasDone = habit.isCompleted(on: appNow())
                    manager.logNumericProgress(habit, value: val)
                    if !wasDone && habit.isCompleted(on: appNow()) {
                        triggerAPFloat()
                    }
                }
                numericText = ""
            }
            Button("Cancel", role: .cancel) { numericText = "" }
        } message: {
            if let target = habit.targetValue, let unit = habit.unit {
                let current = habit.log(for: appNow())?.value ?? 0
                Text("Current: \(String(format: "%.1f", current))/\(String(format: "%.0f", target)) \(unit)")
            }
        }
    }

    @ViewBuilder
    private var completionIndicator: some View {
        switch habit.type {
        case .build:
            if hasBuildOrNumericCompletion {
                checkmark
            } else {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        manager.completeBuildHabit(habit)
                        showCheck = true
                    }
                    triggerAPFloat()
                } label: {
                    ZStack {
                        Circle()
                            .stroke(Color(hex: "2A2A2A"), lineWidth: 1.5)
                            .frame(width: 32, height: 32)
                    }
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
                }
                .buttonStyle(.plain)
            }

        case .quit:
            if hasRelapsedToday {
                ZStack {
                    Circle()
                        .fill(Color(hex: "FF3B30").opacity(0.12))
                        .frame(width: 32, height: 32)
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "FF3B30"))
                }
            } else {
                Button {
                    manager.logRelapse(habit)
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "FF3B30").opacity(0.06))
                            .frame(width: 44, height: 44)
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(hex: "FF3B30").opacity(0.5))
                    }
                    .contentShape(Circle())
                }
                .buttonStyle(.plain)
            }

        case .numeric:
            if hasBuildOrNumericCompletion {
                checkmark
            } else {
                Button {
                    showNumericInput = true
                } label: {
                    ZStack {
                        Circle()
                            .stroke(Color(hex: "2A2A2A"), lineWidth: 1.5)
                            .frame(width: 32, height: 32)
                        Image(systemName: "plus")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color(hex: "555555"))
                    }
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var checkmark: some View {
        ZStack {
            Circle()
                .fill(accent.opacity(0.12))
                .frame(width: 32, height: 32)
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(accent)
        }
        .scaleEffect(showCheck ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.2)) {
                showCheck = true
            }
        }
    }
}
