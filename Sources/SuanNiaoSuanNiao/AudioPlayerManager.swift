import AVFoundation
import Foundation
import OSLog

@MainActor
final class AudioPlayerManager: NSObject {
    private let logger = Logger(subsystem: "com.franco.suanniao", category: "audio")
    private let settingsStore: SettingsStore
    private var player: AVAudioPlayer?

    init(settingsStore: SettingsStore) {
        self.settingsStore = settingsStore
        super.init()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleSettingsChanged),
            name: .settingsDidChange,
            object: settingsStore
        )
    }

    func playReminder() {
        stopCurrentPlayback()

        guard let url = ResourceLocator.audioFileURL() else {
            logger.notice("Missing local audio resource: suanniao.mp3 / suanniao.m4a")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = settingsStore.audioVolume
            player.prepareToPlay()
            player.play()
            self.player = player
        } catch {
            logger.error("Failed to play reminder audio: \(error.localizedDescription, privacy: .public)")
        }
    }

    @objc
    private func handleSettingsChanged() {
        player?.volume = settingsStore.audioVolume
    }

    private func stopCurrentPlayback() {
        player?.stop()
        player = nil
    }
}
