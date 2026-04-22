import SwiftUI

struct AddFriendSearchView: View {
    @Environment(\.dismiss) private var dismiss
    private var friends = FriendService.shared

    @State private var query: String = ""
    @State private var results: [RemoteUser] = []
    @State private var isSearching = false
    @State private var searchTask: Task<Void, Never>?
    @State private var sentToUIDs: Set<String> = []

    var body: some View {
        ZStack {
            AppTheme.bgPure.ignoresSafeArea()

            VStack(spacing: 16) {
                header

                searchField

                if isSearching {
                    ProgressView().tint(.white).padding(.top, 20)
                } else if query.trimmingCharacters(in: .whitespaces).isEmpty {
                    emptyHint
                } else if results.isEmpty {
                    Text("No matches for \"\(query)\"")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.textDim)
                        .padding(.top, 20)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            ForEach(results) { user in
                                resultRow(user)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.bottom, 40)
                    }
                }

                Spacer()
            }
        }
        .presentationDetents([.large])
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack {
            Button("Close") { dismiss() }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppTheme.textMuted)
            Spacer()
            Text("ADD FRIEND")
                .font(.system(size: 11, weight: .bold))
                .tracking(4)
                .foregroundColor(.white)
            Spacer()
            Color.clear.frame(width: 40)
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppTheme.textDim)
            TextField("", text: $query, prompt: Text("search username").foregroundColor(Color(hex: "444444")))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
                .onChange(of: query) { _, new in
                    scheduleSearch(prefix: new)
                }
            if !query.isEmpty {
                Button {
                    query = ""
                    results = []
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.textDim)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.bgCard)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.06), lineWidth: 0.5))
        )
        .padding(.horizontal, 14)
    }

    private var emptyHint: some View {
        VStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 28, weight: .light))
                .foregroundColor(AppTheme.textSubtle)
            Text("Search for a friend by username")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.textDim)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 48)
    }

    private func resultRow(_ user: RemoteUser) -> some View {
        let info = LevelSystem.levelInfo(for: user.totalXP)
        let state: RelationshipState = {
            if sentToUIDs.contains(user.uid) { return .requestSent }
            return friends.relationshipState(for: user.uid)
        }()

        return HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(info.color.opacity(0.15))
                    .frame(width: 36, height: 36)
                Image(systemName: info.icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(info.color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(user.username)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                HStack(spacing: 6) {
                    Text(info.displayName.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .tracking(2)
                        .foregroundColor(info.color)
                    Text("·")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(AppTheme.textDim)
                    Text("\(user.totalXP) AP")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppTheme.textStat)
                }
            }
            Spacer()
            trailingAction(for: user, state: state)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.bgCard)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.05), lineWidth: 0.5))
        )
    }

    @ViewBuilder
    private func trailingAction(for user: RemoteUser, state: RelationshipState) -> some View {
        switch state {
        case .alreadyFriends:
            label("FRIENDS", background: Color(hex: "1A1A1A"), foreground: AppTheme.textMuted)
        case .requestSent:
            label("SENT", background: Color(hex: "1A1A1A"), foreground: AppTheme.textMuted)
        case .requestReceived:
            label("CHECK INBOX", background: AppTheme.accentOrange.opacity(0.2), foreground: AppTheme.accentOrange)
        case .none:
            Button {
                Task { await send(to: user) }
            } label: {
                Text("ADD")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(2)
                    .foregroundColor(.black)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Capsule().fill(.white))
            }
        }
    }

    private func label(_ text: String, background: Color, foreground: Color) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .tracking(2)
            .foregroundColor(foreground)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Capsule().fill(background))
    }

    private func scheduleSearch(prefix: String) {
        searchTask?.cancel()
        let trimmed = prefix.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            results = []
            return
        }
        isSearching = true
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 250_000_000)
            if Task.isCancelled { return }
            do {
                let found = try await friends.search(prefix: trimmed)
                if Task.isCancelled { return }
                await MainActor.run {
                    self.results = found.filter { $0.uid != AuthService.shared.currentUID }
                    self.isSearching = false
                }
            } catch {
                await MainActor.run { self.isSearching = false }
            }
        }
    }

    private func send(to user: RemoteUser) async {
        do {
            try await friends.sendRequest(to: user)
            await MainActor.run { sentToUIDs.insert(user.uid) }
        } catch {
            print("sendRequest failed: \(error)")
        }
    }
}
