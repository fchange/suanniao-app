import AppKit
import SwiftUI

private enum SettingsTheme {
    static let canvasTop = Color(red: 0.95, green: 0.97, blue: 0.995)
    static let canvasBottom = Color(red: 0.90, green: 0.93, blue: 0.98)
    static let text = Color(nsColor: .labelColor)
    static let textSub = Color(nsColor: .secondaryLabelColor)
    static let sidebarTint = Color.white.opacity(0.001)
    static let sectionTint = Color.white.opacity(0.001)
    static let groupTint = Color.white.opacity(0.001)
}

struct SettingsRootView: View {
    @ObservedObject var settingsStore: SettingsStore
    @ObservedObject var selection: SectionSelection

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [SettingsTheme.canvasTop, SettingsTheme.canvasBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            HStack(spacing: 24) {
                SettingsSidebar(
                    selectedSection: selection.section,
                    onSelectSection: selectSection
                )
                .frame(width: 220)

                SettingsDetailContent(
                    section: selection.section,
                    settingsStore: settingsStore
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(24)
        }
    }

    private func selectSection(_ section: SettingsWindowController.Section) {
        withAnimation(.snappy(duration: 0.2)) {
            selection.section = section
        }
    }
}

private struct SettingsSidebar: View {
    let selectedSection: SettingsWindowController.Section
    let onSelectSection: (SettingsWindowController.Section) -> Void

    var body: some View {
        LiquidGlassContainer(spacing: 12) {
            VStack(alignment: .leading, spacing: 10) {
                Text("设置")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(SettingsTheme.textSub)
                    .padding(.bottom, 4)

                ForEach(SettingsWindowController.Section.allCases, id: \.self) { section in
                    SettingsSidebarButton(
                        section: section,
                        isSelected: selectedSection == section,
                        onTap: { onSelectSection(section) }
                    )
                }

                Spacer(minLength: 0)
            }
            .padding(16)
            .background(SettingsTheme.sidebarTint, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .liquidGlassCard(cornerRadius: 20)
        }
    }
}

private struct SettingsSidebarButton: View {
    let section: SettingsWindowController.Section
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Image(systemName: section.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .frame(width: 16)

                Text(section.title)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .medium))

                Spacer(minLength: 0)
            }
            .foregroundStyle(isSelected ? SettingsTheme.text : SettingsTheme.textSub)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                isSelected ? SettingsTheme.sectionTint : Color.clear,
                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
            )
            .liquidGlassCard(cornerRadius: 12, isEnabled: isSelected)
            .contentShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SettingsDetailContent: View {
    let section: SettingsWindowController.Section
    @ObservedObject var settingsStore: SettingsStore

    var body: some View {
        ZStack {
            AppearanceSettingsView(settingsStore: settingsStore)
                .sectionVisibility(section == .appearance)

            AudioSettingsView(settingsStore: settingsStore)
                .sectionVisibility(section == .audio)

            AboutSettingsView()
                .sectionVisibility(section == .about)
        }
        .animation(.snappy(duration: 0.2), value: section)
    }
}

private struct AppearanceSettingsView: View {
    @ObservedObject var settingsStore: SettingsStore

    var body: some View {
        SettingsPage(title: "常规") {
            SettingsGlassGroup {
                ReminderPanelContentView(style: settingsStore.reminderStyle, brandImage: ResourceLocator.brandImage())
                    .frame(height: 210)
            }

            SettingsGlassGroup {
                SettingRow(label: "窗口大小") {
                    Slider(value: $settingsStore.windowScale, in: 0.8...1.55)
                        .frame(width: 180)
                    Text("\(Int((settingsStore.windowScale * 100).rounded()))%")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(SettingsTheme.textSub)
                        .frame(width: 50, alignment: .trailing)
                }

                SettingRow(label: "显示图标") {
                    Toggle("", isOn: $settingsStore.showReminderIcon)
                        .labelsHidden()
                }

                SettingRow(label: "玻璃效果") {
                    Picker("", selection: $settingsStore.glassMode) {
                        ForEach(ReminderGlassMode.allCases, id: \.self) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .frame(width: 240)
                }

                SettingRow(label: "字体大小") {
                    Slider(value: $settingsStore.fontSize, in: 44...108)
                        .frame(width: 180)
                    Text("\(Int(settingsStore.fontSize.rounded())) pt")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(SettingsTheme.textSub)
                        .frame(width: 50, alignment: .trailing)
                }

                SettingRow(label: "文字颜色") {
                    ColorPicker("", selection: Binding(
                        get: { settingsStore.textColor.swiftUIColor },
                        set: { settingsStore.textColor = NSColor($0) ?? settingsStore.textColor }
                    ), supportsOpacity: false)
                    .labelsHidden()
                }

                SettingRow(label: "背景颜色") {
                    ColorPicker("", selection: Binding(
                        get: { settingsStore.backgroundColor.swiftUIColor },
                        set: { settingsStore.backgroundColor = NSColor($0) ?? settingsStore.backgroundColor }
                    ), supportsOpacity: false)
                    .labelsHidden()
                }

                SettingRow(label: "颜色预设") {
                    HStack(spacing: 8) {
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

private struct AudioSettingsView: View {
    @ObservedObject var settingsStore: SettingsStore

    var body: some View {
        SettingsPage(title: "声音") {
            SettingsGlassGroup {
                SettingRow(label: "音量") {
                    Slider(
                        value: Binding(
                            get: { Double(settingsStore.audioVolume) },
                            set: { settingsStore.audioVolume = Float($0) }
                        ),
                        in: 0...1
                    )
                    .frame(width: 180)

                    Text("\(Int((CGFloat(settingsStore.audioVolume) * 100).rounded()))%")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(SettingsTheme.textSub)
                        .frame(width: 50, alignment: .trailing)
                }

                InfoRow(label: "音频文件", value: "suanniao.mp3")
                InfoRow(label: "触发时机", value: "点击菜单栏")
            }
        }
    }
}

private struct AboutSettingsView: View {
    var body: some View {
        SettingsPage(title: "关于") {
            SettingsGlassGroup {
                InfoRow(label: "应用", value: "蒜鸟蒜鸟")
                InfoRow(label: "版本", value: appVersionText)
                InfoRow(label: "平台", value: "macOS 14+")
            }

            SettingsGlassGroup {
                Text("「蒜鸟蒜鸟」来自武汉方言里的「算了」。这个应用希望在情绪上头的时候，用更柔和的方式提醒你停一下。")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(SettingsTheme.textSub)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
        ScrollView {
            LiquidGlassContainer(spacing: 20) {
                VStack(alignment: .leading, spacing: 20) {
                    Text(title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(SettingsTheme.text)

                    content
                }
                .padding(32)
            }
        }
        .scrollIndicators(.hidden)
    }
}

private struct SettingsGlassGroup<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .padding(16)
        .background(SettingsTheme.groupTint, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .liquidGlassCard(cornerRadius: 18)
    }
}

private struct SettingRow<Content: View>: View {
    let label: String
    let content: Content

    init(label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(SettingsTheme.text)
            Spacer()
            content
        }
        .padding(.vertical, 12)
    }
}

private struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(SettingsTheme.text)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(SettingsTheme.textSub)
        }
        .padding(.vertical, 12)
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
                    Circle().stroke(
                        isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.4),
                        lineWidth: isSelected ? 2 : 1
                    )
                )
                .liquidGlass(in: AnyShape(Circle()), isEnabled: isSelected)
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
    var icon: String {
        switch self {
        case .appearance: "slider.horizontal.3"
        case .audio: "speaker.wave.2"
        case .about: "info.circle"
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
