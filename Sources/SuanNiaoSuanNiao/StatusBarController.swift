import AppKit

@MainActor
final class StatusBarController: NSObject, NSMenuDelegate {
    var onLeftClick: (() -> Void)?
    var onOpenAbout: (() -> Void)?
    var onOpenSettings: (() -> Void)?
    var onQuit: (() -> Void)?

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let contextMenu = NSMenu()

    func install() {
        configureButton()
        configureMenu()
    }

    private func configureButton() {
        guard let button = statusItem.button else { return }

        let image = loadStatusBarImage()
        let showsImage = image != nil
        button.image = image
        button.imagePosition = showsImage ? .imageOnly : .noImage
        button.imageScaling = .scaleProportionallyDown
        button.toolTip = "蒜鸟蒜鸟"
        button.target = self
        button.action = #selector(handleStatusItemClick(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])

        // Keep a visible fallback when the icon cannot be loaded.
        button.title = showsImage ? "" : "蒜"
        button.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
        button.contentTintColor = showsImage ? nil : .labelColor
    }

    private func configureMenu() {
        contextMenu.delegate = self
        contextMenu.addItem(
            withTitle: "关于『蒜鸟蒜鸟』",
            action: #selector(openAbout),
            keyEquivalent: ""
        )
        contextMenu.addItem(
            withTitle: "设置...",
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        contextMenu.addItem(.separator())
        contextMenu.addItem(
            withTitle: "退出",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        contextMenu.items.forEach { $0.target = self }
    }

    @objc
    private func handleStatusItemClick(_ sender: Any?) {
        guard let event = NSApp.currentEvent else {
            onLeftClick?()
            return
        }

        if isSecondaryClick(event) {
            presentContextMenu()
        } else {
            onLeftClick?()
        }
    }

    private func isSecondaryClick(_ event: NSEvent) -> Bool {
        event.type == .rightMouseUp ||
        (event.type == .leftMouseUp && event.modifierFlags.contains(.control))
    }

    private func presentContextMenu() {
        statusItem.menu = contextMenu
        statusItem.button?.performClick(nil)
    }

    func menuDidClose(_ menu: NSMenu) {
        statusItem.menu = nil
    }

    @objc
    private func openAbout() {
        onOpenAbout?()
    }

    @objc
    private func openSettings() {
        onOpenSettings?()
    }

    @objc
    private func quitApp() {
        onQuit?()
    }

    private func loadStatusBarImage() -> NSImage? {
        if let image = ResourceLocator.statusBarImage() {
            return image
        }

        let fallback = NSImage(
            systemSymbolName: "bubble.left.fill",
            accessibilityDescription: "蒜鸟蒜鸟"
        )
        fallback?.isTemplate = true
        return fallback
    }
}
