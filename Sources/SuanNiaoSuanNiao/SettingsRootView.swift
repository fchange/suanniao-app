import AppKit
import SwiftUI

private enum SettingsUI {
    static let windowBackground = Color(red: 0.97, green: 0.97, blue: 0.98)
    static let cardBackground = Color.white
    static let sidebarBackground = Color.white
    static let rowHighlight = Color(red: 0.94, green: 0.94, blue: 0.95)
    static let border = Color.black.opacity(0.08)
    static let separator = Color.black.opacity(0.07)
    static let primaryText = Color(nsColor: .labelColor)
    static let secondaryText = Color(nsColor: .secondaryLabelColor)
    static let tertiaryText = Color(nsColor: .tertiaryLabelColor)
    static let accent = Color(nsColor: .controlAccentColor)
}

struct SettingsRootView: View {
    @ObservedObject var settingsStore: SettingsStore
    @ObservedObject var selection: SectionSelection

    var body: some View {
        ZStack {
            SettingsUI.windowBackground
                .ignoresSafeArea()

            HStack(spacing: 0) {
                sidebar
                    .frame(width: 272)

                Rectangle()
                    .fill(SettingsUI.separator)
                    .frame(width: 1)

                detailContainer
            }
            .background(SettingsUI.cardBackground, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(SettingsUI.border, lineWidth: 1)
            )
            .padding(24)
        }
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                Group {
                    if let image = ResourceLocator.brandImage() {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                            .padding(6)
                    } else {
                        Image(systemName: "bird.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(SettingsUI.primaryText)
                    }
                }
                .frame(width: 40, height: 40)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(SettingsUI.border, lineWidth: 1)
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text("蒜鸟蒜鸟")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(SettingsUI.primaryText)

                    Text("设置")
                        .font(.system(size: 12))
                        .foregroundStyle(SettingsUI.secondaryText)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)

            VStack(spacing: 4) {
                ForEach(SettingsWindowController.Section.allCases, id: \.self) { section in
                    sidebarButton(for: section)
                }
            }
            .padding(.horizontal, 12)

            Spacer(minLength: 0)
        }
        .background(SettingsUI.sidebarBackground)
    }

    private var detailContainer: some View {
        Group {
            switch selection.section {
            case .appearance:
                AppearanceSettingsView(settingsStore: settingsStore)
            case .audio:
                AudioSettingsView(settingsStore: settingsStore)
            case .about:
                AboutSettingsView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white)
    }

    private func sidebarButton(for section: SettingsWindowController.Section) -> some View {
        let isSelected = selection.section == section

        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selection.section = section
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: section.icon)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(isSelected ? SettingsUI.primaryText : SettingsUI.secondaryText)
                    .frame(width: 22)

                Text(section.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(SettingsUI.primaryText)

                Spacer(minLength: 8)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? SettingsUI.rowHighlight : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct AppearanceSettingsView: View {
    @ObservedObject var settingsStore: SettingsStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                SettingsHeader(title: "提醒外观")

                SettingsTable {
                    SettingsPreviewRow(
                        title: "实时预览",
                        subtitle: "当前提醒样式会立即显示在这里。",
                        style: settingsStore.reminderStyle,
                        brandImage: ResourceLocator.brandImage()
                    )

                    SettingsSliderRow(
                        title: "提醒窗口大小",
                        value: Binding(
                            get: { settingsStore.windowScale },
                            set: { settingsStore.windowScale = $0 }
                        ),
                        range: 0.8...1.55,
                        displayValue: "\(Int((settingsStore.windowScale * 100).rounded()))%"
                    )

                    SettingsSliderRow(
                        title: "字体大小",
                        value: Binding(
                            get: { settingsStore.fontSize },
                            set: { settingsStore.fontSize = $0 }
                        ),
                        range: 44...108,
                        displayValue: "\(Int(settingsStore.fontSize.rounded())) pt"
                    )

                    SettingsSliderRow(
                        title: "文字透明度",
                        value: Binding(
                            get: { settingsStore.textOpacity },
                            set: { settingsStore.textOpacity = $0 }
                        ),
                        range: 0.25...1.0,
                        displayValue: "\(Int((settingsStore.textOpacity * 100).rounded()))%"
                    )

                    SettingsToggleRow(
                        title: "显示品牌图标",
                        isOn: $settingsStore.showReminderIcon
                    )

                    SettingsSegmentedRow(
                        title: "磨砂玻璃",
                        selection: $settingsStore.glassMode,
                        options: ReminderGlassMode.allCases
                    ) { mode in
                        mode.title
                    }

                    SettingsColorRow(
                        title: "文字颜色",
                        selection: Binding(
                            get: { settingsStore.textColor.swiftUIColor },
                            set: { settingsStore.textColor = NSColor($0) ?? settingsStore.textColor }
                        ),
                        hex: settingsStore.textColor.hexString
                    )

                    SettingsColorRow(
                        title: "提醒背景色",
                        selection: Binding(
                            get: { settingsStore.backgroundColor.swiftUIColor },
                            set: { settingsStore.backgroundColor = NSColor($0) ?? settingsStore.backgroundColor }
                        ),
                        hex: settingsStore.backgroundColor.hexString
                    )

                    SettingsSliderRow(
                        title: "背景透明度",
                        value: Binding(
                            get: { settingsStore.backgroundOpacity },
                            set: { settingsStore.backgroundOpacity = $0 }
                        ),
                        range: 0.2...1.0,
                        displayValue: "\(Int((settingsStore.backgroundOpacity * 100).rounded()))%"
                    )

                    PresetPaletteRow(
                        title: "颜色预设",
                        presets: ReminderColorPreset.morandiPalette,
                        selectedHex: settingsStore.backgroundColor.hexString
                    ) { preset in
                        settingsStore.applyPreset(preset)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .scrollIndicators(.hidden)
    }
}

private struct AudioSettingsView: View {
    @ObservedObject var settingsStore: SettingsStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                SettingsHeader(title: "声音")

                SettingsTable {
                    SettingsSliderRow(
                        title: "提醒音量",
                        value: Binding(
                            get: { Double(settingsStore.audioVolume) },
                            set: { settingsStore.audioVolume = Float($0) }
                        ),
                        range: 0...1,
                        displayValue: "\(Int((CGFloat(settingsStore.audioVolume) * 100).rounded()))%"
                    )

                    ReadOnlyRow(
                        title: "音频文件",
                        value: "Resources/Audio/suanniao.mp3"
                    )

                    ReadOnlyRow(
                        title: "播放方式",
                        value: "点击菜单栏图标时播放"
                    )

                    ReadOnlyRow(
                        title: "替换说明",
                        value: "保持文件名不变即可"
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .scrollIndicators(.hidden)
    }
}

private struct AboutSettingsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                SettingsHeader(title: "关于蒜鸟")

                SettingsTable {
                    ReadOnlyRow(
                        title: "应用名称",
                        value: "蒜鸟蒜鸟"
                    )

                    ReadOnlyRow(
                        title: "版本",
                        value: appVersionText
                    )

                    ReadOnlyRow(
                        title: "平台",
                        value: "macOS 14 及以上"
                    )

                    TextBlockRow(
                        title: "说明",
                        text: "“蒜鸟蒜鸟”来自武汉方言里的“算了”。这个应用希望在情绪上头的时候，用更柔和的方式提醒你停一下。"
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .scrollIndicators(.hidden)
    }

    private var appVersionText: String {
        let bundle = Bundle.main
        let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }
}

private struct SettingsHeader: View {
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 30, weight: .semibold))
                .foregroundStyle(SettingsUI.primaryText)
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 20)

            Rectangle()
                .fill(SettingsUI.separator)
                .frame(height: 1)
        }
    }
}

private struct SettingsTable<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(SettingsUI.border, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .padding(.top, 24)
    }
}

private struct SettingsRowContainer<Content: View>: View {
    let content: Content
    var showsDivider: Bool = true

    init(showsDivider: Bool = true, @ViewBuilder content: () -> Content) {
        self.showsDivider = showsDivider
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            content
                .padding(.horizontal, 22)
                .padding(.vertical, 20)

            if showsDivider {
                Rectangle()
                    .fill(SettingsUI.separator)
                    .frame(height: 1)
            }
        }
    }
}

private struct SettingsPreviewRow: View {
    let title: String
    let subtitle: String
    let style: ReminderStyle
    let brandImage: NSImage?

    var body: some View {
        SettingsRowContainer {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(SettingsUI.primaryText)

                    Spacer(minLength: 12)

                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(SettingsUI.secondaryText)
                }

                ReminderPanelContentView(style: style, brandImage: brandImage)
                    .frame(height: 248)
            }
        }
    }
}

private struct SettingsSliderRow<V>: View where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    let title: String
    let value: Binding<V>
    let range: ClosedRange<V>
    let displayValue: String

    var body: some View {
        SettingsRowContainer {
            HStack(alignment: .center, spacing: 24) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(SettingsUI.primaryText)

                Spacer(minLength: 20)

                HStack(spacing: 14) {
                    Slider(value: value, in: range)
                        .frame(width: 220)

                    Text(displayValue)
                        .font(.system(size: 13))
                        .foregroundStyle(SettingsUI.secondaryText)
                        .frame(width: 70, alignment: .trailing)
                }
            }
        }
    }
}

private struct SettingsToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        SettingsRowContainer {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(SettingsUI.primaryText)

                Spacer(minLength: 20)

                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .toggleStyle(.switch)
            }
        }
    }
}

private struct SettingsSegmentedRow<Option>: View where Option: Hashable {
    let title: String
    @Binding var selection: Option
    let options: [Option]
    let label: (Option) -> String

    var body: some View {
        SettingsRowContainer {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(SettingsUI.primaryText)

                Spacer(minLength: 20)

                Picker(title, selection: $selection) {
                    ForEach(options, id: \.self) { option in
                        Text(label(option)).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 240)
                .labelsHidden()
            }
        }
    }
}

private struct SettingsColorRow: View {
    let title: String
    let selection: Binding<Color>
    let hex: String

    var body: some View {
        SettingsRowContainer {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(SettingsUI.primaryText)

                Spacer(minLength: 20)

                HStack(spacing: 12) {
                    Text(hex)
                        .font(.system(size: 13))
                        .foregroundStyle(SettingsUI.secondaryText)

                    ColorPicker("", selection: selection, supportsOpacity: false)
                        .labelsHidden()
                }
            }
        }
    }
}

private struct PresetPaletteRow: View {
    let title: String
    let presets: [ReminderColorPreset]
    let selectedHex: String
    let action: (ReminderColorPreset) -> Void

    var body: some View {
        SettingsRowContainer(showsDivider: false) {
            HStack(alignment: .top, spacing: 20) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(SettingsUI.primaryText)
                    .padding(.top, 4)

                Spacer(minLength: 20)

                LazyVGrid(columns: Array(repeating: GridItem(.fixed(44), spacing: 10), count: 3), spacing: 10) {
                    ForEach(presets) { preset in
                        let isSelected = preset.color.hexString == selectedHex

                        Button {
                            action(preset)
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(preset.color.swiftUIColor)

                                Text("蒜")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(preset.textColor.swiftUIColor)
                            }
                            .frame(width: 44, height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(isSelected ? SettingsUI.primaryText : SettingsUI.border, lineWidth: isSelected ? 2 : 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .help(preset.name)
                    }
                }
            }
        }
    }
}

private struct ReadOnlyRow: View {
    let title: String
    let value: String

    var body: some View {
        SettingsRowContainer {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(SettingsUI.primaryText)

                Spacer(minLength: 20)

                Text(value)
                    .font(.system(size: 15))
                    .foregroundStyle(SettingsUI.secondaryText)
            }
        }
    }
}

private struct TextBlockRow: View {
    let title: String
    let text: String

    var body: some View {
        SettingsRowContainer(showsDivider: false) {
            HStack(alignment: .top, spacing: 20) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(SettingsUI.primaryText)

                Spacer(minLength: 20)

                Text(text)
                    .font(.system(size: 15))
                    .foregroundStyle(SettingsUI.secondaryText)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 360, alignment: .trailing)
            }
        }
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
}
