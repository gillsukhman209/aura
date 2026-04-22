import SwiftUI

struct FriendProfileSheet: View {
    let friend: RemoteUser

    @Environment(\.dismiss) private var dismiss
    private var friends = FriendService.shared

    @State private var latest: RemoteUser?
    @State private var showRemoveConfirm = false
    @State private var isRemoving = false

    init(friend: RemoteUser) {
        self.friend = friend
    }

    private var user: RemoteUser { latest ?? friend }

    var body: some View {
        ZStack {
            AppTheme.bgPure.ignoresSafeArea()
            StarfieldBackground(starCount: 40).opacity(0.2)

            VStack(spacing: 20) {
                header
                Spacer().frame(height: 4)
                rankBadge
                usernameBlock
                statsGrid
                Spacer()
                removeButton
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .presentationDetents([.medium, .large])
        .preferredColorScheme(.dark)
        .task {
            latest = try? await friends.fetchUser(uid: friend.uid)
        }
        .alert("Remove friend?", isPresented: $showRemoveConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Remove", role: .destructive) {
                Task { await remove() }
            }
        } message: {
            Text("\(user.username) will be removed from your leaderboard.")
        }
    }

    private var header: some View {
        HStack {
            Button("Close") { dismiss() }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppTheme.textMuted)
            Spacer()
            Color.clear.frame(width: 40)
        }
        .padding(.top, 14)
    }

    private var rankBadge: some View {
        let info = LevelSystem.levelInfo(for: user.totalXP)
        return ZStack {
            Circle()
                .fill(info.color.opacity(0.15))
                .frame(width: 88, height: 88)
            Image(systemName: info.icon)
                .font(.system(size: 34, weight: .semibold))
                .foregroundColor(info.color)
        }
    }

    private var usernameBlock: some View {
        let info = LevelSystem.levelInfo(for: user.totalXP)
        return VStack(spacing: 4) {
            Text(user.username)
                .font(.system(size: 22, weight: .black))
                .foregroundColor(.white)
            Text(info.displayName.uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(4)
                .foregroundColor(info.color)
        }
    }

    private var statsGrid: some View {
        let nowKey = WeekKey.current()
        let weekly = user.effectiveWeeklyXP(nowKey: nowKey)
        return HStack(spacing: 10) {
            statCard(label: "WEEK", value: "\(weekly)", suffix: "AP", color: .white)
            statCard(label: "TOTAL", value: "\(user.totalXP)", suffix: "AP", color: AppTheme.gold)
            statCard(
                label: "STREAK",
                value: "\(user.currentStreak)",
                suffix: user.currentStreak == 1 ? "DAY" : "DAYS",
                color: AppTheme.accentOrange,
                icon: "flame.fill"
            )
        }
    }

    private func statCard(label: String, value: String, suffix: String, color: Color, icon: String? = nil) -> some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(3)
                .foregroundColor(AppTheme.textDim)
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(color)
                }
                Text(value)
                    .font(.system(size: 22, weight: .black))
                    .foregroundColor(color)
            }
            Text(suffix)
                .font(.system(size: 9, weight: .bold))
                .tracking(2)
                .foregroundColor(AppTheme.textDim)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppTheme.bgCard)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.05), lineWidth: 0.5))
        )
    }

    private var removeButton: some View {
        Group {
            if friends.friendUIDs.contains(user.uid) {
                Button {
                    showRemoveConfirm = true
                } label: {
                    Text(isRemoving ? "REMOVING…" : "REMOVE FRIEND")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(3)
                        .foregroundColor(AppTheme.accentDanger)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AppTheme.accentDanger.opacity(0.08))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.accentDanger.opacity(0.3), lineWidth: 0.5))
                        )
                }
                .disabled(isRemoving)
            }
        }
    }

    private func remove() async {
        isRemoving = true
        defer { isRemoving = false }
        do {
            try await friends.remove(friendUID: user.uid)
            dismiss()
        } catch {
            print("remove failed: \(error)")
        }
    }
}
