import SwiftUI

struct FriendsTabView: View {
    @Environment(HabitManager.self) private var manager
    private var friends = FriendService.shared
    private var auth = AuthService.shared

    @State private var showSearch = false
    @State private var showInbox = false
    @State private var selectedFriend: RemoteUser?

    var body: some View {
        ZStack {
            AppTheme.bgPure.ignoresSafeArea()
            StarfieldBackground(starCount: 60).opacity(0.2)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    header

                    if friends.leaderboard.isEmpty {
                        emptyState
                    } else {
                        ForEach(sortedRows(), id: \.uid) { row in
                            leaderboardRow(row)
                                .onTapGesture {
                                    if row.uid != auth.currentUID {
                                        selectedFriend = row
                                    }
                                }
                        }
                    }

                    Spacer().frame(height: 120)
                }
                .padding(.horizontal, 14)
            }
        }
        .sheet(isPresented: $showSearch) {
            AddFriendSearchView()
        }
        .sheet(isPresented: $showInbox) {
            FriendRequestsInboxView()
        }
        .sheet(item: $selectedFriend) { friend in
            FriendProfileSheet(friend: friend)
        }
        .onAppear { Analytics.screen("Friends") }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("FRIENDS")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(4)
                    .foregroundColor(Color(hex: "555555"))
                Text("Weekly leaderboard")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.textMuted)
            }
            Spacer()

            Button {
                showInbox = true
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "tray.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.textBright)
                        .frame(width: 38, height: 38)
                        .background(
                            RoundedRectangle(cornerRadius: 10).fill(AppTheme.bgCard)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.06), lineWidth: 0.5))
                        )
                    if !friends.incomingRequests.isEmpty {
                        Circle()
                            .fill(AppTheme.accentDanger)
                            .frame(width: 10, height: 10)
                            .overlay(Circle().stroke(AppTheme.bgPure, lineWidth: 2))
                            .offset(x: 3, y: -3)
                    }
                }
            }

            Button {
                showSearch = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 38, height: 38)
                    .background(RoundedRectangle(cornerRadius: 10).fill(.white))
            }
        }
        .padding(.top, 14)
        .padding(.bottom, 4)
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 28, weight: .light))
                .foregroundColor(AppTheme.textSubtle)
            Text("No friends yet")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppTheme.textMuted)
            Text("Add friends to see them on your weekly leaderboard.")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.textDim)
                .multilineTextAlignment(.center)

            Button { showSearch = true } label: {
                Text("ADD A FRIEND")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(3)
                    .foregroundColor(.black)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 8).fill(.white))
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }

    // MARK: - Rows

    private func sortedRows() -> [RemoteUser] {
        let nowKey = WeekKey.current()
        var rows = friends.leaderboard
        // Include self on top-row order by weekly XP too.
        if let uid = auth.currentUID, !rows.contains(where: { $0.uid == uid }) {
            rows.append(selfRow())
        }
        rows.sort { lhs, rhs in
            let lw = lhs.effectiveWeeklyXP(nowKey: nowKey)
            let rw = rhs.effectiveWeeklyXP(nowKey: nowKey)
            if lw != rw { return lw > rw }
            return lhs.totalXP > rhs.totalXP
        }
        return rows
    }

    private func selfRow() -> RemoteUser {
        RemoteUser(
            uid: auth.currentUID ?? "",
            username: auth.currentUsername ?? "you",
            usernameLower: (auth.currentUsername ?? "you").lowercased(),
            totalXP: manager.profile?.totalXP ?? 0,
            weeklyXP: 0, // local-only; remote doc is the source of truth
            weekResetKey: "",
            currentStreak: manager.profile?.currentStreak ?? 0,
            longestStreak: manager.profile?.longestStreak ?? 0,
            createdAt: manager.profile?.createdAt ?? Date()
        )
    }

    private func leaderboardRow(_ user: RemoteUser) -> some View {
        let isSelf = user.uid == auth.currentUID
        let info = LevelSystem.levelInfo(for: user.totalXP)
        let nowKey = WeekKey.current()
        let weekly = user.effectiveWeeklyXP(nowKey: nowKey)

        return HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(info.color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: info.icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(info.color)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(user.username)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    if isSelf {
                        Text("YOU")
                            .font(.system(size: 8, weight: .bold))
                            .tracking(2)
                            .foregroundColor(.black)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(.white))
                    }
                }
                HStack(spacing: 6) {
                    Text(info.displayName.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .tracking(2)
                        .foregroundColor(info.color)
                    Text("·")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(AppTheme.textDim)
                    Image(systemName: "flame.fill")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(AppTheme.accentOrange)
                    Text("\(user.currentStreak)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppTheme.textStat)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text("\(weekly)")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(.white)
                Text("AP THIS WEEK")
                    .font(.system(size: 8, weight: .bold))
                    .tracking(2)
                    .foregroundColor(AppTheme.textDim)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(AppTheme.bgCard)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isSelf ? Color.white.opacity(0.15) : Color.white.opacity(0.05), lineWidth: 0.5)
                )
        )
    }
}
