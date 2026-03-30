import AppKit
import Foundation
import SwiftUI

struct ReminderStyle {
    let fontSize: CGFloat
    let textOpacity: CGFloat
    let textColor: NSColor
    let showIcon: Bool
    let windowScale: CGFloat
    let backgroundColor: NSColor
    let backgroundOpacity: CGFloat
}

struct ReminderColorPreset: Identifiable, Equatable {
    let id: String
    let name: String
    let color: NSColor

    static let morandiPalette: [ReminderColorPreset] = [
        .init(id: "mist-apricot", name: "杏雾", color: NSColor(calibratedRed: 0.90, green: 0.82, blue: 0.77, alpha: 1)),
        .init(id: "sage-ash", name: "鼠尾灰", color: NSColor(calibratedRed: 0.75, green: 0.80, blue: 0.74, alpha: 1)),
        .init(id: "lake-fog", name: "湖雾", color: NSColor(calibratedRed: 0.73, green: 0.80, blue: 0.84, alpha: 1)),
        .init(id: "plum-dust", name: "梅灰", color: NSColor(calibratedRed: 0.76, green: 0.72, blue: 0.78, alpha: 1)),
        .init(id: "tea-milk", name: "奶茶", color: NSColor(calibratedRed: 0.84, green: 0.77, blue: 0.70, alpha: 1)),
        .init(id: "shell-sand", name: "贝砂", color: NSColor(calibratedRed: 0.86, green: 0.84, blue: 0.79, alpha: 1))
    ]
}

extension Notification.Name {
    static let settingsDidChange = Notification.Name("SettingsStore.didChange")
}

@MainActor
final class SettingsStore: ObservableObject {
    static let shared = SettingsStore()

    private enum Keys {
        static let fontSize = "settings.fontSize"
        static let textOpacity = "settings.textOpacity"
        static let textColor = "settings.textColor"
        static let audioVolume = "settings.audioVolume"
        static let showReminderIcon = "settings.showReminderIcon"
        static let windowScale = "settings.windowScale"
        static let backgroundColor = "settings.backgroundColor"
        static let backgroundOpacity = "settings.backgroundOpacity"
    }

    private let defaults: UserDefaults

    @Published var fontSize: CGFloat {
        didSet {
            let clamped = Self.clamp(fontSize, min: 44, max: 108)
            guard fontSize == clamped else {
                fontSize = clamped
                return
            }
            persistCGFloat(fontSize, forKey: Keys.fontSize)
            notifyChange()
        }
    }

    @Published var textOpacity: CGFloat {
        didSet {
            let clamped = Self.clamp(textOpacity, min: 0.25, max: 1.0)
            guard textOpacity == clamped else {
                textOpacity = clamped
                return
            }
            persistCGFloat(textOpacity, forKey: Keys.textOpacity)
            notifyChange()
        }
    }

    @Published var textColor: NSColor {
        didSet {
            persistColor(textColor, forKey: Keys.textColor)
            notifyChange()
        }
    }

    @Published var audioVolume: Float {
        didSet {
            let clamped = Float(Self.clamp(CGFloat(audioVolume), min: 0, max: 1))
            guard audioVolume == clamped else {
                audioVolume = clamped
                return
            }
            defaults.set(audioVolume, forKey: Keys.audioVolume)
            notifyChange()
        }
    }

    @Published var showReminderIcon: Bool {
        didSet {
            defaults.set(showReminderIcon, forKey: Keys.showReminderIcon)
            notifyChange()
        }
    }

    @Published var windowScale: CGFloat {
        didSet {
            let clamped = Self.clamp(windowScale, min: 0.8, max: 1.55)
            guard windowScale == clamped else {
                windowScale = clamped
                return
            }
            persistCGFloat(windowScale, forKey: Keys.windowScale)
            notifyChange()
        }
    }

    @Published var backgroundColor: NSColor {
        didSet {
            persistColor(backgroundColor, forKey: Keys.backgroundColor)
            notifyChange()
        }
    }

    @Published var backgroundOpacity: CGFloat {
        didSet {
            let clamped = Self.clamp(backgroundOpacity, min: 0.2, max: 1.0)
            guard backgroundOpacity == clamped else {
                backgroundOpacity = clamped
                return
            }
            persistCGFloat(backgroundOpacity, forKey: Keys.backgroundOpacity)
            notifyChange()
        }
    }

    var reminderStyle: ReminderStyle {
        ReminderStyle(
            fontSize: fontSize,
            textOpacity: textOpacity,
            textColor: textColor,
            showIcon: showReminderIcon,
            windowScale: windowScale,
            backgroundColor: backgroundColor,
            backgroundOpacity: backgroundOpacity
        )
    }

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        fontSize = CGFloat(defaults.object(forKey: Keys.fontSize) as? Double ?? 60)
        textOpacity = CGFloat(defaults.object(forKey: Keys.textOpacity) as? Double ?? 0.88)
        textColor = Self.loadColor(from: defaults.data(forKey: Keys.textColor))
            ?? NSColor(calibratedWhite: 0.98, alpha: 1)
        audioVolume = defaults.object(forKey: Keys.audioVolume) as? Float ?? 0.85
        showReminderIcon = defaults.object(forKey: Keys.showReminderIcon) as? Bool ?? true
        windowScale = CGFloat(defaults.object(forKey: Keys.windowScale) as? Double ?? 1.0)
        backgroundColor = Self.loadColor(from: defaults.data(forKey: Keys.backgroundColor))
            ?? ReminderColorPreset.morandiPalette[0].color
        backgroundOpacity = CGFloat(defaults.object(forKey: Keys.backgroundOpacity) as? Double ?? 0.82)

        fontSize = Self.clamp(fontSize, min: 44, max: 108)
        textOpacity = Self.clamp(textOpacity, min: 0.25, max: 1.0)
        audioVolume = Float(Self.clamp(CGFloat(audioVolume), min: 0, max: 1))
        windowScale = Self.clamp(windowScale, min: 0.8, max: 1.55)
        backgroundOpacity = Self.clamp(backgroundOpacity, min: 0.2, max: 1.0)
    }

    func applyPreset(_ preset: ReminderColorPreset) {
        backgroundColor = preset.color
    }

    private func notifyChange() {
        NotificationCenter.default.post(name: .settingsDidChange, object: self)
    }

    private func persistCGFloat(_ value: CGFloat, forKey key: String) {
        defaults.set(Double(value), forKey: key)
    }

    private func persistColor(_ color: NSColor, forKey key: String) {
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true) else {
            return
        }
        defaults.set(data, forKey: key)
    }

    private static func loadColor(from data: Data?) -> NSColor? {
        guard let data else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data)
    }

    private static func clamp<T: Comparable>(_ value: T, min: T, max: T) -> T {
        Swift.max(min, Swift.min(value, max))
    }
}

extension NSColor {
    var swiftUIColor: Color {
        Color(nsColor: self)
    }

    var hexString: String {
        guard let rgb = usingColorSpace(.deviceRGB) else { return "#FFFFFF" }
        let red = Int((rgb.redComponent * 255).rounded())
        let green = Int((rgb.greenComponent * 255).rounded())
        let blue = Int((rgb.blueComponent * 255).rounded())
        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}
