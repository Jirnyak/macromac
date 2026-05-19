import Foundation
import IOKit.hid

final class HardwareKeyMonitor {
    private let manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
    private var isStarted = false
    var onUsage: ((Int, Int, Bool) -> Void)?

    func start() {
        guard !isStarted else {
            return
        }

        isStarted = true
        IOHIDManagerSetDeviceMatching(manager, nil)
        IOHIDManagerRegisterInputValueCallback(
            manager,
            { context, _, _, value in
                guard let context else {
                    return
                }

                let monitor = Unmanaged<HardwareKeyMonitor>
                    .fromOpaque(context)
                    .takeUnretainedValue()
                monitor.handle(value)
            },
            Unmanaged.passUnretained(self).toOpaque()
        )
        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
        IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
    }

    func stop() {
        guard isStarted else {
            return
        }

        IOHIDManagerUnscheduleFromRunLoop(manager, CFRunLoopGetMain(), CFRunLoopMode.commonModes.rawValue)
        IOHIDManagerClose(manager, IOOptionBits(kIOHIDOptionsTypeNone))
        isStarted = false
    }

    private func handle(_ value: IOHIDValue) {
        let element = IOHIDValueGetElement(value)
        let page = Int(IOHIDElementGetUsagePage(element))
        let usage = Int(IOHIDElementGetUsage(element))
        let isPress = IOHIDValueGetIntegerValue(value) != 0
        guard isInteresting(page: page) else {
            return
        }
        onUsage?(page, usage, isPress)
    }

    private func isInteresting(page: Int) -> Bool {
        switch page {
        case 0x07, 0x0c, 0x00ff, 0xff00, 0xff01:
            return true
        default:
            return false
        }
    }
}
