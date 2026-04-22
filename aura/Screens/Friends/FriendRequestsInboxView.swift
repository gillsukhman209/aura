import SwiftUI

struct FriendRequestsInboxView: View {
    @Environment(\.dismiss) private var dismiss
    private var friends = FriendService.shared

    var body: some View {
        ZStack {
            AppTheme.bgPure.ignoresSafeArea()

            VStack(spacing: 16) {
                header

                if friends.incomingRequests.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "tray")
                            .font(.system(size: 28, weight: .light))
                            .foregroundColor(AppTheme.textSubtle)
                        Text("No pending requests")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(AppTheme.textDim)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 48)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            ForEach(friends.incomingRequests) { request in
                                row(request)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.bottom, 40)
                    }
                }

                Spacer()
            }
        }
        .presentationDetents([.medium, .large])
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack {
            Button("Close") { dismiss() }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(AppTheme.textMuted)
            Spacer()
            Text("REQUESTS")
                .font(.system(size: 11, weight: .bold))
                .tracking(4)
                .foregroundColor(.white)
            Spacer()
            Color.clear.frame(width: 40)
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
    }

    private func row(_ request: FriendRequest) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 36, height: 36)
                Image(systemName: "person.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.textBright)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(request.fromUsername)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text("wants to be your friend")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.textDim)
            }
            Spacer()

            Button {
                Task { try? await friends.decline(request) }
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppTheme.textMuted)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(Color(hex: "1A1A1A")))
            }

            Button {
                Task { try? await friends.accept(request) }
            } label: {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(.white))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppTheme.bgCard)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.05), lineWidth: 0.5))
        )
    }
}
