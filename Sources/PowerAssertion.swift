import Foundation
import IOKit
import IOKit.pwr_mgt

final class PowerAssertion {
    private var assertionID: IOPMAssertionID = 0
    private var isHeld = false

    func acquire(reason: String = "Caffeinated is keeping your Mac awake") -> Bool {
        guard !isHeld else { return true }
        let result = IOPMAssertionCreateWithName(
            kIOPMAssertPreventUserIdleDisplaySleep as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            reason as CFString,
            &assertionID
        )
        guard result == kIOReturnSuccess else { return false }
        isHeld = true
        return true
    }

    func release() {
        guard isHeld else { return }
        IOPMAssertionRelease(assertionID)
        assertionID = 0
        isHeld = false
    }

    deinit { release() }
}
