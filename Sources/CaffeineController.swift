import Foundation
import SwiftUI

@MainActor
final class CaffeineController: ObservableObject {
    @Published private(set) var isActive = false
    @Published private(set) var expirationDate: Date?

    private let assertion = PowerAssertion()
    private var timer: Timer?

    private let kWasActive = "wasActiveOnQuit"
    private let kExpirationDate = "expirationDate"
    private let kRestoreOnLaunch = "restoreOnLaunch"

    init() {
        restoreIfNeeded()
    }

    func activate(duration: TimeInterval?) {
        guard assertion.acquire() else { return }
        isActive = true
        timer?.invalidate()
        timer = nil

        if let duration {
            let expiry = Date().addingTimeInterval(duration)
            expirationDate = expiry
            timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
                Task { @MainActor in self?.deactivate() }
            }
        } else {
            expirationDate = nil
        }

        persistState()
    }

    /// Keep awake until the next occurrence of the given time of day.
    /// If the chosen time has already passed today, it rolls over to tomorrow.
    func activate(until timeOfDay: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: timeOfDay)
        guard let target = Calendar.current.nextDate(
            after: Date(),
            matching: components,
            matchingPolicy: .nextTime
        ) else { return }
        activate(duration: target.timeIntervalSinceNow)
    }

    func deactivate() {
        assertion.release()
        timer?.invalidate()
        timer = nil
        isActive = false
        expirationDate = nil
        persistState()
    }

    private func persistState() {
        let defaults = UserDefaults.standard
        defaults.set(isActive, forKey: kWasActive)
        if let expiry = expirationDate {
            defaults.set(expiry, forKey: kExpirationDate)
        } else {
            defaults.removeObject(forKey: kExpirationDate)
        }
    }

    private func restoreIfNeeded() {
        let defaults = UserDefaults.standard
        guard defaults.bool(forKey: kRestoreOnLaunch),
              defaults.bool(forKey: kWasActive) else { return }

        if let saved = defaults.object(forKey: kExpirationDate) as? Date {
            let remaining = saved.timeIntervalSinceNow
            if remaining > 0 {
                activate(duration: remaining)
            } else {
                defaults.removeObject(forKey: kExpirationDate)
                defaults.set(false, forKey: kWasActive)
            }
        } else {
            activate(duration: nil)
        }
    }
}
