import Foundation
import SuperwallKit

@Observable
class SubscriptionManager: SuperwallDelegate {
    static let shared = SubscriptionManager()
    var isPaidUser: Bool = false

    private init() {
        // Set initial state
        isPaidUser = Superwall.shared.subscriptionStatus.isActive
    }

    // MARK: - SuperwallDelegate

    func subscriptionStatusDidChange(from oldValue: SubscriptionStatus, to newValue: SubscriptionStatus) {
        switch newValue {
        case .active:
            isPaidUser = true
        case .inactive, .unknown:
            isPaidUser = false
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
