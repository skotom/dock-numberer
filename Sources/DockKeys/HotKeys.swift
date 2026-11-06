import Carbon.HIToolbox

/// Registers Cmd+1…9 and Cmd+0 as global hotkeys (no Accessibility permission needed).
final class HotKeys {
    // Slot 1…9 then 10 (the "0" key), as ANSI virtual key codes.
    private static let keyCodes: [UInt32] = [
        UInt32(kVK_ANSI_1), UInt32(kVK_ANSI_2), UInt32(kVK_ANSI_3),
        UInt32(kVK_ANSI_4), UInt32(kVK_ANSI_5), UInt32(kVK_ANSI_6),
        UInt32(kVK_ANSI_7), UInt32(kVK_ANSI_8), UInt32(kVK_ANSI_9),
        UInt32(kVK_ANSI_0),
    ]

    private var refs: [EventHotKeyRef?] = []
    private var handlerRef: EventHandlerRef?
    var onSlot: ((Int) -> Void)?   // zero-based slot index

    func register() {
        var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                 eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, event, userData in
            guard let event, let userData else { return OSStatus(eventNotHandledErr) }
            var id = EventHotKeyID()
            GetEventParameter(event, EventParamName(kEventParamDirectObject),
                              EventParamType(typeEventHotKeyID), nil,
                              MemoryLayout<EventHotKeyID>.size, nil, &id)
            let me = Unmanaged<HotKeys>.fromOpaque(userData).takeUnretainedValue()
            me.onSlot?(Int(id.id))
            return noErr
        }, 1, &spec, Unmanaged.passUnretained(self).toOpaque(), &handlerRef)

        for (slot, code) in Self.keyCodes.enumerated() {
            var ref: EventHotKeyRef?
            let id = EventHotKeyID(signature: OSType(0x444B4559) /* 'DKEY' */, id: UInt32(slot))
            RegisterEventHotKey(code, UInt32(cmdKey), id, GetApplicationEventTarget(), 0, &ref)
            refs.append(ref)
        }
    }

    func unregister() {
        refs.compactMap { $0 }.forEach { UnregisterEventHotKey($0) }
        refs.removeAll()
    }
}
