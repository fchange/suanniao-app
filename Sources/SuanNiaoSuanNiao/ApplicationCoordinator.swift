import AppKit

@MainActor
final class ApplicationCoordinator {
    private let settingsStore = SettingsStore.shared
    private lazy var audioPlayerManager = AudioPlayerManager(settingsStore: settingsStore)
    private lazy var reminderPanelController = ReminderPanelController(settingsStore: settingsStore)
    private lazy var statusBarController = StatusBarController()
    private lazy var settingsWindowController = SettingsWindowController(settingsStore: settingsStore)

    func start() {
        statusBarController.onLeftClick = { [weak self] in
            self?.handlePrimaryAction()
        }
        statusBarController.onOpenAbout = { [weak self] in
            self?.showAbout()
        }
        statusBarController.onOpenSettings = { [weak self] in
            self?.showSettings()
        }
        statusBarController.onQuit = {
            NSApp.terminate(nil)
        }
        statusBarController.install()
    }

    private func handlePrimaryAction() {
        reminderPanelController.presentReminder()
        audioPlayerManager.playReminder()
    }

    private func showAbout() {
        settingsWindowController.show(section: .about)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func showSettings() {
        settingsWindowController.show(section: .appearance)
        NSApp.activate(ignoringOtherApps: true)
    }
}
