import AppKit
import ApplicationServices
import CoreGraphics

/// Periodically nudges the cursor by a pixel and back so apps that track
/// user presence (chat status, idle timers) see activity.
/// Posting synthetic mouse events requires Accessibility permission.
@MainActor
final class CursorWiggler {
    static let enabledKey = "wiggleCursor"

    private let interval: TimeInterval = 2 * 60
    /// Skip the wiggle if the user has touched the mouse or keyboard more recently than this.
    private let minimumIdle: TimeInterval = 60
    private var timer: Timer?

    static var isTrusted: Bool { AXIsProcessTrusted() }

    /// Shows the system Accessibility prompt if the app isn't trusted yet.
    @discardableResult
    static func requestTrust() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    func start() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick() }
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard UserDefaults.standard.bool(forKey: Self.enabledKey),
              Self.isTrusted,
              secondsSinceLastInput() >= minimumIdle else { return }
        wiggle()
    }

    private func secondsSinceLastInput() -> TimeInterval {
        let anyInput = CGEventType(rawValue: ~0)!
        return CGEventSource.secondsSinceLastEventType(.hidSystemState, eventType: anyInput)
    }

    private func wiggle() {
        guard let origin = CGEvent(source: nil)?.location else { return }
        let nudged = CGPoint(x: origin.x + 1, y: origin.y)
        postMove(to: nudged)
        postMove(to: origin)
    }

    private func postMove(to point: CGPoint) {
        CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: point, mouseButton: .left)?
            .post(tap: .cghidEventTap)
    }
}
