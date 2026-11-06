import AppKit
import ServiceManagement

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private var statusItem: NSStatusItem!
    private let hotKeys = HotKeys()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(systemSymbolName: "command.square",
                                           accessibilityDescription: "DockKeys")
        let menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu

        hotKeys.onSlot = { [weak self] slot in self?.launch(slot: slot) }
        hotKeys.register()
    }

    private func launch(slot: Int) {
        let apps = DockReader.pinnedApps()
        guard slot < apps.count else { NSSound.beep(); return }
        let config = NSWorkspace.OpenConfiguration()
        config.activates = true
        NSWorkspace.shared.openApplication(at: apps[slot], configuration: config)
    }

    // Rebuild the menu each time it opens so it reflects the current Dock.
    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        let apps = DockReader.pinnedApps()
        if apps.isEmpty {
            menu.addItem(withTitle: "No pinned Dock apps found", action: nil, keyEquivalent: "")
        }
        for (i, url) in apps.enumerated() {
            let name = FileManager.default.displayName(atPath: url.path)
                .replacingOccurrences(of: ".app", with: "")
            menu.addItem(withTitle: "⌘\(i == 9 ? 0 : i + 1)  \(name)", action: nil, keyEquivalent: "")
        }
        menu.addItem(.separator())

        let login = NSMenuItem(title: "Launch at Login", action: #selector(toggleLogin), keyEquivalent: "")
        login.target = self
        login.state = SMAppService.mainApp.status == .enabled ? .on : .off
        menu.addItem(login)
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit DockKeys", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    }

    @objc private func toggleLogin() {
        let service = SMAppService.mainApp
        do {
            if service.status == .enabled { try service.unregister() } else { try service.register() }
        } catch {
            NSLog("DockKeys: launch-at-login failed: \(error)")
        }
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)   // menu bar only, no Dock icon
let delegate = AppDelegate()
app.delegate = delegate
app.run()
