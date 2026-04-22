import SwiftUI
import SwiftData

struct UsernameSetupView: View {
    let onClaimed: () -> Void

    @Environment(HabitManager.self) private var manager
    @Environment(\.modelContext) private var modelContext
    @State private var username: String = ""
    @State private var error: String?
    @State private var isClaiming = false
    @FocusState private var focused: Bool

    var body: some View {
        ZStack {
            Color(hex: "050505").ignoresSafeArea()
            StarfieldBackground(starCount: 60).opacity(0.2)

            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 8) {
                    Text("PICK YOUR USERNAME")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: "555555"))
                        .tracking(4)
                    Text("How friends will find you")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "C0C0C0"))
                }

                TextField("", text: $username, prompt: Text("username").foregroundColor(Color(hex: "444444")))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focused)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "0A0A0A"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 0.5)
                            )
                    )
                    .padding(.horizontal, 24)
                    .onChange(of: username) { _, new in
                        username = String(new.filter { $0.isLetter || $0.isNumber || $0 == "_" }.prefix(20))
                    }

                Text("3–20 chars · letters, numbers, _")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(hex: "3A3A3A"))

                if let error {
                    Text(error)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.accentDanger)
                        .padding(.horizontal, 24)
                        .multilineTextAlignment(.center)
                }

                Button {
                    Task { await claim() }
                } label: {
                    Text(isClaiming ? "CLAIMING…" : "CLAIM")
                        .font(.system(size: 13, weight: .bold))
                        .tracking(4)
                        .foregroundColor(AuthService.isValidUsername(username) ? .black : Color(hex: "555555"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(AuthService.isValidUsername(username) ? Color.white : Color(hex: "1A1A1A"))
                        )
                        .padding(.horizontal, 24)
                }
                .disabled(!AuthService.isValidUsername(username) || isClaiming)

                Spacer()
            }
        }
        .onAppear { focused = true }
    }

    private func claim() async {
        guard !isClaiming else { return }
        error = nil
        isClaiming = true
        defer { isClaiming = false }

        let payload = manager.profile.map { RemoteProfileService.shared.migrationPayload(from: $0) } ?? [:]

        do {
            let claimed = try await AuthService.shared.claimUsername(username, migrationPayload: payload)
            if let profile = manager.profile {
                profile.username = claimed
                profile.remoteUID = AuthService.shared.currentUID
                try? modelContext.save()
            }
            onClaimed()
        } catch {
            self.error = (error as? AuthError)?.errorDescription ?? error.localizedDescription
        }
    }
}
