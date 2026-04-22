import Foundation
import SuperwallKit

@Observable
class SubscriptionManager: SuperwallDelegate {
    static let shared = SubscriptionManager()
    var isPaidUser: Bool = false
    var paywallDidDismissWithoutPurchase: Bool = false

    /// Debug builds always unlock the app so we can iterate without hitting the paywall.
    static let debugUnlock: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()

    private init() {
        isPaidUser = Self.debugUnlock || Superwall.shared.subscriptionStatus.isActive
    }

    // MARK: - SuperwallDelegate

    func subscriptionStatusDidChange(from oldValue: SubscriptionStatus, to newValue: SubscriptionStatus) {
        if Self.debugUnlock {
            isPaidUser = true
            return
        }
        switch newValue {
        case .active:
            isPaidUser = true
        case .inactive, .unknown:
            isPaidUser = false
        }
    }

    func handleSuperwallEvent(withInfo eventInfo: SuperwallEventInfo) {
        if case .paywallClose = eventInfo.event {
            if !Superwall.shared.subscriptionStatus.isActive {
                paywallDidDismissWithoutPurchase = true
            }
        }
    }

    // MARK: - Paywall Presentation

    /// Register a placement. If a paywall is configured for it in the dashboard,
    /// it will be shown. The `feature` closure runs when the user has access.
    func registerPlacement(_ placement: String, feature: @escaping () -> Void) {
        Superwall.shared.register(placement: placement, feature: feature)
    }

    /// Register a placement without a feature gate (for analytics/future paywalls).
    func registerPlacement(_ placement: String) {
        Superwall.shared.register(placement: placement)
    }
}
