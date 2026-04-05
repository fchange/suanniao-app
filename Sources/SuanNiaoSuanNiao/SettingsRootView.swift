import AppKit
import SwiftUI

private enum SettingsTheme {
    static let canvasStart = Color(red: 0.94, green: 0.95, blue: 0.98)
    static let canvasEnd = Color(red: 0.90, green: 0.92, blue: 0.96)
    static let shellBackground = Color(red: 0.985, green: 0.982, blue: 0.973)
    static let sidebarBackground = Color(red: 0.965, green: 0.968, blue: 0.982)
    static let contentBackground = Color(red: 0.992, green: 0.989, blue: 0.982)
    static let cardBackground = Color.white.opacity(0.88)
    static let divider = Color.black.opacity(0.07)
    static let text = Color(red: 0.17, green: 0.20, blue: 0.27)
    static let textSecondary = Color(red: 0.45, green: 0.49, blue: 0.57)
    static let muted = Color(red: 0.78, green: 0.80, blue: 0.84)
    static let accent = Color(red: 0.61, green: 0.27, blue: 0.18)
    static let accentSoft = Color(red: 0.88, green: 0.81, blue: 0.77)
    static let sidebarSelection = Color(red: 0.89, green: 0.91, blue: 0.95)
    static let shadow = Color.black.opacity(0.08)
}

struct SettingsRootView: View {
    @ObservedObject var settingsStore: SettingsStore
    @ObservedObject var selection: SectionSelection

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [SettingsTheme.canvasStart, SettingsTheme.canvasEnd],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            SettingsShell {
                HStack(spacing: 0) {
                    SettingsSidebar(
                        selectedSection: selection.section,
                        onSelectSection: selectSection
                    )
                    .frame(width: 260)

                    Rectangle()
                        .fill(SettingsTheme.divider)
                        .frame(width: 1)

                    SettingsDetailContent(
                        section: selection.section,
                        settingsStore: settingsStore
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(SettingsTheme.contentBackground)
                }
            }
            .padding(18)
        }
    }

    private func selectSection(_ section: SettingsWindowController.Section) {
        withAnimation(.snappy(duration: 0.2)) {
            selection.section = section
        }
    }
}

private struct SettingsShell<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .background(SettingsTheme.shellBackground)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(Color.white.opacity(0.75), lineWidth: 1)
            )
            .shadow(color: SettingsTheme.shadow, radius: 30, x: 0, y: 16)
    }
}

private struct SettingsSidebar: View {
    let selectedSection: SettingsWindowController.Section
    let onSelectSection: (SettingsWindowController.Section) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Preferences")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(SettingsTheme.text)

                Text("v\(appVersion)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(SettingsTheme.textSecondary)
            }
            .padding(.top, 28)
            .padding(.horizontal, 22)
            .padding(.bottom, 28)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(SettingsWindowController.Section.allCases, id: \.self) { section in
                    SettingsSidebarButton(
                        section: section,
                        isSelected: selectedSection == section,
                        onTap: { onSelectSection(section) }
                    )
                }
            }
            .padding(.horizontal, 14)

            Spacer(minLength: 0)
        }
        .background(SettingsTheme.sidebarBackground)
    }

    private var appVersion: String {
        let bundle = Bundle.main
        return bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    }
}

private struct SettingsSidebarButton: View {
    let section: SettingsWindowController.Section
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                Image(systemName: section.icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isSelected ? SettingsTheme.text : SettingsTheme.textSecondary)
                    .frame(width: 20)

                Text(section.title)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(isSelected ? SettingsTheme.text : SettingsTheme.textSecondary)

                Spacer(minLength: 0)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? SettingsTheme.sidebarSelection : Color.clear)
            )
            .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct SettingsDetailContent: View {
    let section: SettingsWindowController.Section
    @ObservedObject var settingsStore: SettingsStore

    var body: some View {
        ZStack {
            GeneralSettingsView(settingsStore: settingsStore)
                .sectionVisibility(section == .general)

            AppearanceSettingsView(settingsStore: settingsStore)
                .sectionVisibility(section == .appearance)

            HotkeySettingsView()
                .sectionVisibility(section == .hotkeys)

            AboutSettingsView()
                .sectionVisibility(section == .about)
        }
        .animation(.snappy(duration: 0.2), value: section)
    }
}

private struct GeneralSettingsView: View {
    @ObservedObject var settingsStore: SettingsStore

    var body: some View {
        SettingsPage(title: "General") {
            VStack(spacing: 18) {
                SettingsCard {
                    VStack(spacing: 20) {
                        LabeledSettingRow(
                            title: "Window Size",
                            value: "\(Int((settingsStore.windowScale * 100).rounded()))%"
                        ) {
                            AccentSlider(value: $settingsStore.windowScale, range: 0.8...1.55)
                        }

                        DividerLine()

                        LabeledSettingRow(title: "Display Icon") {
                            Toggle("", isOn: $settingsStore.showReminderIcon)
                                .toggleStyle(.switch)
                                .tint(SettingsTheme.accent)
                                .labelsHidden()
                        }

                        DividerLine()

                        VStack(alignment: .leading, spacing: 14) {
                            HStack(alignment: .firstTextBaseline) {
                                Text("Glass Effect")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(SettingsTheme.text)

                                Spacer(minLength: 0)
                            }

                            Picker("", selection: $settingsStore.glassMode) {
                                ForEach(ReminderGlassMode.allCases, id: \.self) { mode in
                                    Text(mode.title).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            .labelsHidden()
                        }
                    }
                }

                SettingsCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Background Color")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(SettingsTheme.text)

                        HStack(spacing: 14) {
                            ColorPicker(
                                "",
                                selection: Binding(
                                    get: { settingsStore.backgroundColor.swiftUIColor },
                                    set: { settingsStore.backgroundColor = NSColor($0) ?? settingsStore.backgroundColor }
                                ),
                                supportsOpacity: false
                            )
                            .labelsHidden()

                            Text(settingsStore.backgroundColor.hexString)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(SettingsTheme.textSecondary)

                            Spacer(minLength: 0)
                        }

                        HStack(spacing: 10) {
                            ForEach(ReminderColorPreset.morandiPalette) { preset in
                                ColorPresetButton(
                                    preset: preset,
                                    isSelected: settingsStore.backgroundColor.isEqual(to: preset.color),
                                    onSelect: { settingsStore.applyPreset(preset) }
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct AppearanceSettingsView: View {
    @ObservedObject var settingsStore: SettingsStore

    var body: some View {
        SettingsPage(title: "Appearance") {
            VStack(spacing: 18) {
                SettingsCard {
                    VStack(alignment: .leading, spacing: 22) {
                        HStack(alignment: .firstTextBaseline) {
                            Text("Font Size")
                                .font(.system(size: 19, weight: .semibold))
                                .foregroundStyle(SettingsTheme.text)

                            Spacer(minLength: 0)

                            HStack(spacing: 42) {
                                Text("SMALL")
                                Text("LARGE")
                            }
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(SettingsTheme.textSecondary.opacity(0.82))
                        }

                        AccentSlider(value: $settingsStore.fontSize, range: 44...108)

                        HStack(spacing: 14) {
                            Text("\(Int(settingsStore.fontSize.rounded())) pt")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(SettingsTheme.accent)

                            Spacer(minLength: 0)
                        }
                    }
                }

                HStack(alignment: .top, spacing: 18) {
                    SettingsCard {
                        VStack(alignment: .leading, spacing: 18) {
                            HStack(alignment: .firstTextBaseline) {
                                Text("Text Opacity")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(SettingsTheme.text)

                                Spacer(minLength: 0)

                                Text("\(Int((settingsStore.textOpacity * 100).rounded()))%")
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundStyle(SettingsTheme.accent)
                            }

                            AccentSlider(value: $settingsStore.textOpacity, range: 0.25...1.0)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    SettingsCard {
                        VStack(alignment: .leading, spacing: 18) {
                            HStack(alignment: .firstTextBaseline) {
                                Text("Audio Volume")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(SettingsTheme.text)

                                Spacer(minLength: 0)

                                Image(systemName: settingsStore.audioVolume <= 0.01 ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(SettingsTheme.accent)
                            }

                            AccentSlider(
                                value: Binding(
                                    get: { Double(settingsStore.audioVolume) },
                                    set: { settingsStore.audioVolume = Float($0) }
                                ),
                                range: 0...1
                            )
                        }
                    }
                    .frame(maxWidth: .infinity)
                }

                SettingsCard {
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Text Color")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(SettingsTheme.text)

                            Text("Main display accent color")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(SettingsTheme.textSecondary)
                        }

                        Spacer(minLength: 0)

                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(settingsStore.textColor.swiftUIColor)
                                .frame(width: 86, height: 44)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color.white.opacity(0.85), lineWidth: 3)
                                )
                                .shadow(color: SettingsTheme.shadow, radius: 8, x: 0, y: 4)

                            Text(settingsStore.textColor.hexString)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(SettingsTheme.textSecondary)

                            ColorPicker(
                                "",
                                selection: Binding(
                                    get: { settingsStore.textColor.swiftUIColor },
                                    set: { settingsStore.textColor = NSColor($0) ?? settingsStore.textColor }
                                ),
                                supportsOpacity: false
                            )
                            .labelsHidden()
                        }
                    }
                }

                SettingsCard {
                    ZStack(alignment: .top) {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        SettingsTheme.accentSoft.opacity(0.85),
                                        Color(red: 0.83, green: 0.89, blue: 0.88).opacity(0.85)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        VStack(spacing: 20) {
                            Text("PREVIEW AREA")
                                .font(.system(size: 13, weight: .bold))
                                .tracking(2.2)
                                .foregroundStyle(SettingsTheme.textSecondary.opacity(0.7))
                                .padding(.top, 26)

                            ReminderPanelContentView(
                                style: settingsStore.reminderStyle,
                                brandImage: ResourceLocator.brandImage()
                            )
                            .frame(height: 240)
                            .padding(.horizontal, 34)
                            .padding(.bottom, 28)
                        }
                    }
                }
            }
        }
    }
}

private struct HotkeySettingsView: View {
    var body: some View {
        SettingsPage(title: "Hotkeys") {
            SettingsCard {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Quick access")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(SettingsTheme.text)

                    Text("The app currently triggers from the menu bar icon. Keyboard shortcut customization is reserved for a later version.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(SettingsTheme.textSecondary)
                        .lineSpacing(4)

                    HStack(spacing: 10) {
                        HotkeyKeycap(label: "⌘")
                        HotkeyKeycap(label: "Click")
                    }
                }
            }
        }
    }
}

private struct AboutSettingsView: View {
    var body: some View {
        SettingsPage(title: "About") {
            VStack(spacing: 18) {
                SettingsCard {
                    VStack(spacing: 18) {
                        InfoLine(label: "App", value: "蒜鸟蒜鸟")
                        DividerLine()
                        InfoLine(label: "Version", value: appVersionText)
                        DividerLine()
                        InfoLine(label: "Platform", value: "macOS 14+")
                    }
                }

                SettingsCard {
                    Text("「蒜鸟蒜鸟」来自武汉方言里的「算了」。这个应用希望在情绪上头的时候，用更柔和的方式提醒你停一下。")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(SettingsTheme.textSecondary)
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private var appVersionText: String {
        let bundle = Bundle.main
        let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }
}

private struct SettingsPage<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(SettingsTheme.text)

                Spacer(minLength: 0)

                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color(red: 0.58, green: 0.64, blue: 0.76))
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 18)

            Rectangle()
                .fill(SettingsTheme.divider)
                .frame(height: 1)

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    content
                }
                .padding(28)
            }
            .scrollIndicators(.hidden)
        }
    }
}

private struct SettingsCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(SettingsTheme.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.92), lineWidth: 1)
        )
        .shadow(color: SettingsTheme.shadow, radius: 12, x: 0, y: 5)
    }
}

private struct LabeledSettingRow<Content: View>: View {
    let title: String
    let value: String?
    let content: Content

    init(title: String, value: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.value = value
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(SettingsTheme.text)

                Spacer(minLength: 0)

                if let value {
                    Text(value)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(SettingsTheme.accent)
                }
            }

            content
        }
    }
}

private struct AccentSlider<Value: BinaryFloatingPoint>: View where Value.Stride: BinaryFloatingPoint {
    @Binding var value: Value
    let range: ClosedRange<Value>

    var body: some View {
        Slider(value: $value, in: range)
            .tint(SettingsTheme.accent)
            .controlSize(.large)
    }
}

private struct DividerLine: View {
    var body: some View {
        Rectangle()
            .fill(SettingsTheme.divider)
            .frame(height: 1)
    }
}

private struct InfoLine: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(SettingsTheme.text)

            Spacer(minLength: 0)

            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(SettingsTheme.textSecondary)
        }
    }
}

private struct HotkeyKeycap: View {
    let label: String

    var body: some View {
        Text(label)
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(SettingsTheme.text)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.white.opacity(0.9))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(SettingsTheme.divider, lineWidth: 1)
            )
    }
}

private struct ColorPresetButton: View {
    let preset: ReminderColorPreset
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            Circle()
                .fill(preset.color.swiftUIColor)
                .frame(width: 28, height: 28)
                .overlay(
                    Circle()
                        .stroke(isSelected ? SettingsTheme.accent : Color.white.opacity(0.8), lineWidth: isSelected ? 3 : 1.5)
                )
                .shadow(color: SettingsTheme.shadow, radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}

private extension View {
    func sectionVisibility(_ isVisible: Bool) -> some View {
        opacity(isVisible ? 1 : 0)
            .allowsHitTesting(isVisible)
            .accessibilityHidden(!isVisible)
    }
}

private extension SettingsWindowController.Section {
    var title: String {
        switch self {
        case .general: "General"
        case .appearance: "Appearance"
        case .hotkeys: "Hotkeys"
        case .about: "About"
        }
    }

    var icon: String {
        switch self {
        case .general: "gearshape.fill"
        case .appearance: "paintpalette.fill"
        case .hotkeys: "command"
        case .about: "info.circle.fill"
        }
    }
}

private extension NSColor {
    convenience init?(_ color: Color) {
        guard let cgColor = color.cgColor else { return nil }
        self.init(cgColor: cgColor)
    }

    func isEqual(to color: NSColor) -> Bool {
        guard
            let lhs = usingColorSpace(.deviceRGB),
            let rhs = color.usingColorSpace(.deviceRGB)
        else {
            return self == color
        }

        return abs(lhs.redComponent - rhs.redComponent) < 0.002
            && abs(lhs.greenComponent - rhs.greenComponent) < 0.002
            && abs(lhs.blueComponent - rhs.blueComponent) < 0.002
            && abs(lhs.alphaComponent - rhs.alphaComponent) < 0.002
    }
}
