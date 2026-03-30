import AppKit
import QuartzCore
import SwiftUI

@MainActor
final class ReminderPanelController: NSWindowController {
    private let settingsStore: SettingsStore
    private var hostingView: NSHostingView<ReminderPanelContentView>?
    private var hideWorkItem: DispatchWorkItem?

    init(settingsStore: SettingsStore) {
        self.settingsStore = settingsStore

        let panel = ReminderPanel()
        super.init(window: panel)

        configurePanel(panel)
        configureContent()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSettingsChanged),
            name: .settingsDidChange,
            object: settingsStore
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func presentReminder() {
        guard let panel = window else { return }

        refreshContent()

        let targetFrame = makeTargetFrame()
        let startFrame = targetFrame.insetBy(
            dx: targetFrame.width * 0.05,
            dy: targetFrame.height * 0.05
        )

        hideWorkItem?.cancel()
        panel.alphaValue = 0
        panel.setFrame(startFrame, display: true)
        panel.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.24
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1
            panel.animator().setFrame(targetFrame, display: true)
        }

        let workItem = DispatchWorkItem { [weak self] in
            self?.dismissReminder()
        }
        hideWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: workItem)
    }

    @objc
    private func handleSettingsChanged() {
        refreshContent()

        guard let panel = window, panel.isVisible else { return }
        panel.setFrame(makeTargetFrame(), display: true, animate: false)
    }

    private func dismissReminder() {
        guard let panel = window else { return }

        let endFrame = panel.frame.insetBy(
            dx: panel.frame.width * 0.03,
            dy: panel.frame.height * 0.03
        )

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.18
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().alphaValue = 0
            panel.animator().setFrame(endFrame, display: true)
        }, completionHandler: {
            DispatchQueue.main.async {
                panel.orderOut(nil)
                panel.alphaValue = 1
            }
        })
    }

    private func configurePanel(_ panel: ReminderPanel) {
        panel.styleMask = [.borderless, .nonactivatingPanel, .fullSizeContentView]
        panel.level = .statusBar
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.hidesOnDeactivate = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        panel.ignoresMouseEvents = true
    }

    private func configureContent() {
        guard let panel = window else { return }

        let hostingView = NSHostingView(rootView: makeContentView())
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        self.hostingView = hostingView

        let container = NSView(frame: NSRect(origin: .zero, size: NSSize(width: 500, height: 300)))
        container.wantsLayer = true
        container.layer?.backgroundColor = NSColor.clear.cgColor
        container.addSubview(hostingView)

        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: container.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        panel.contentView = container
    }

    private func refreshContent() {
        hostingView?.rootView = makeContentView()
    }

    private func makeContentView() -> ReminderPanelContentView {
        ReminderPanelContentView(
            style: settingsStore.reminderStyle,
            brandImage: ResourceLocator.brandImage()
        )
    }

    private func makeTargetFrame() -> NSRect {
        let style = settingsStore.reminderStyle
        let font = NSFont.systemFont(ofSize: style.fontSize, weight: .bold)
        let textSize = ("蒜鸟蒜鸟" as NSString).size(withAttributes: [.font: font])
        let scale = style.windowScale
        let iconHeight: CGFloat = style.showIcon ? 94 : 18
        let width = max(360, ceil((textSize.width + 180) * scale))
        let height = max(200, ceil((textSize.height + 110 + iconHeight) * scale))
        let size = NSSize(width: width, height: height)

        let visibleFrame = targetScreen()?.visibleFrame
            ?? NSScreen.main?.visibleFrame
            ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
        let origin = NSPoint(
            x: visibleFrame.midX - (size.width / 2),
            y: visibleFrame.midY - (size.height / 2) + min(52, visibleFrame.height * 0.08)
        )

        return NSRect(origin: origin, size: size)
    }

    private func targetScreen() -> NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        return NSScreen.screens.first(where: { $0.frame.contains(mouseLocation) }) ?? NSScreen.main
    }
}

private final class ReminderPanel: NSPanel {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 300),
            styleMask: [.borderless, .nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
}
