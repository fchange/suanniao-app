import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController: NSWindowController {
    enum Section: String, CaseIterable, Hashable {
        case appearance
        case audio
        case about

        var title: String {
            switch self {
            case .appearance: "常规"
            case .audio: "声音"
            case .about: "关于"
            }
        }
    }

    private let settingsStore: SettingsStore
    private let selection = SectionSelection()
    private var hostingView: NSHostingView<SettingsRootView>?

    init(settingsStore: SettingsStore) {
        self.settingsStore = settingsStore

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1280, height: 820),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "蒜鸟蒜鸟"
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.backgroundColor = .clear
        window.isOpaque = false
        window.isReleasedWhenClosed = false
        // Prevent control drags (e.g. Slider) from being interpreted as window dragging.
        window.isMovableByWindowBackground = false
        window.toolbarStyle = .unified
        window.minSize = NSSize(width: 1060, height: 700)
        window.center()

        super.init(window: window)
        configureWindow()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        window?.makeKeyAndOrderFront(sender)
    }

    func show(section: Section) {
        selection.section = section
        showWindow(nil)
    }

    private func configureWindow() {
        guard let contentView = window?.contentView else { return }

        let rootView = SettingsRootView(settingsStore: settingsStore, selection: selection)
        let hostingView = NSHostingView(rootView: rootView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        self.hostingView = hostingView

        contentView.addSubview(hostingView)
        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

@MainActor
final class SectionSelection: ObservableObject {
    @Published var section: SettingsWindowController.Section = .appearance
}
