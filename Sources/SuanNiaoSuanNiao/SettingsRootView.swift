import AppKit
import SwiftUI

private enum SettingsUI {
    static let windowBackground = Color(red: 0.95, green: 0.95, blue: 0.96)
    static let frameBackground = Color.white
    static let sidebarBackground = Color(red: 0.985, green: 0.985, blue: 0.985)
    static let detailBackground = Color.white
    static let rowHighlight = Color(red: 0.94, green: 0.94, blue: 0.95)
    static let rowControlBackground = Color(red: 0.965, green: 0.965, blue: 0.965)
    static let border = Color.black.opacity(0.08)
    static let separator = Color.black.opacity(0.075)
    static let primaryText = Color(nsColor: .labelColor)
    static let secondaryText = Color(nsColor: .secondaryLabelColor)
    static let tertiaryText = Color(nsColor: .tertiaryLabelColor)
    static let outerCorner: CGFloat = 26
    static let groupCorner: CGFloat = 14
    static let controlCorner: CGFloat = 11
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
                    .frame(width: 268)

                Rectangle()
                    .fill(SettingsUI.separator)
                    .frame(width: 1)

                detailContainer
            }
            .background(SettingsUI.frameBackground, in: RoundedRectangle(cornerRadius: SettingsUI.outerCorner, style: .continuous))
            .clipShape(RoundedRectangle(cornerRadius: SettingsUI.outerCorner, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SettingsUI.outerCorner, style: .continuous)
                    .stroke(SettingsUI.border, lineWidth: 1)
            )
            .padding(6)
        }
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button(action: closeSettingsWindow) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 12, weight: .semibold))
                    Text("返回应用")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundStyle(SettingsUI.secondaryText)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 18)
            .padding(.top, 18)

            VStack(spacing: 4) {
                ForEach(SettingsWindowController.Section.allCases, id: \.self) { section in
                    sidebarButton(for: section)
                }
            }
            .padding(.horizontal, 10)

            Spacer(minLength: 0)

            HStack(spacing: 8) {
                Group {
                    if let image = ResourceLocator.brandImage() {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                            .padding(4)
                    } else {
                        Image(systemName: "bird.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(SettingsUI.primaryText)
                    }
                }
                .frame(width: 20, height: 20)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .stroke(SettingsUI.border, lineWidth: 1)
                )

                VStack(alignment: .leading, spacing: 0) {
                    Text("蒜鸟蒜鸟")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(SettingsUI.secondaryText)
                    Text("设置")
                        .font(.system(size: 11))
                        .foregroundStyle(SettingsUI.tertiaryText)
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 18)
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
        .background(SettingsUI.detailBackground)
    }

    private func sidebarButton(for section: SettingsWindowController.Section) -> some View {
        let isSelected = selection.section == section

        return Button {
            withAnimation(.easeInOut(duration: 0.16)) {
                selection.section = section
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: section.icon)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(isSelected ? SettingsUI.primaryText : SettingsUI.secondaryText)
                    .frame(width: 18)

                Text(section.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(SettingsUI.primaryText)

                Spacer(minLength: 10)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isSelected ? SettingsUI.rowHighlight : .clear)
            )
        }
        .buttonStyle(.plain)
    }

    private func closeSettingsWindow() {
        NSApp.keyWindow?.performClose(nil)
    }
}

private struct AppearanceSettingsView: View {
    @ObservedObject var settingsStore: SettingsStore

    var body: some View {
        SettingsPage(title: "常规") {
            SettingsGroup {
                SettingsPreviewRow(
                    title: "实时预览",
                    subtitle: "当前提醒样式会立即显示在这里。",
                    style: settingsStore.reminderStyle,
                    brandImage: ResourceLocator.brandImage()
                )

                SettingsSliderRow(
                    title: "提醒窗口大小",
                    subtitle: "调整提醒面板整体缩放比例。",
                    value: Binding(
                        get: { settingsStore.windowScale },
                        set: { settingsStore.windowScale = $0 }
                    ),
                    range: 0.8...1.55,
                    displayValue: "\(Int((settingsStore.windowScale * 100).rounded()))%"
                )

                SettingsToggleRow(
                    title: "显示品牌图标",
                    subtitle: "在提醒文字前显示蒜鸟图标。",
                    isOn: $settingsStore.showReminderIcon
                )

                SettingsSegmentedRow(
                    title: "磨砂玻璃",
                    subtitle: "调节提醒卡片的玻璃质感层级。",
                    selection: $settingsStore.glassMode,
                    options: ReminderGlassMode.allCases,
                    showsDivider: false
                ) { mode in
                    mode.title
                }
            }

            SettingsGroup(title: "外观") {
                SettingsSliderRow(
                    title: "字体大小",
                    subtitle: "设置提醒文本字号。",
                    value: Binding(
                        get: { settingsStore.fontSize },
                        set: { settingsStore.fontSize = $0 }
                    ),
                    range: 44...108,
                    displayValue: "\(Int(settingsStore.fontSize.rounded())) pt"
                )

                SettingsSliderRow(
                    title: "文字透明度",
                    subtitle: "控制提醒文本可见度。",
                    value: Binding(
                        get: { settingsStore.textOpacity },
                        set: { settingsStore.textOpacity = $0 }
                    ),
                    range: 0.25...1.0,
                    displayValue: "\(Int((settingsStore.textOpacity * 100).rounded()))%"
                )

                SettingsColorRow(
                    title: "文字颜色",
                    subtitle: "选择提醒文案颜色。",
                    selection: Binding(
                        get: { settingsStore.textColor.swiftUIColor },
                        set: { settingsStore.textColor = NSColor($0) ?? settingsStore.textColor }
                    ),
                    hex: settingsStore.textColor.hexString
                )

                SettingsColorRow(
                    title: "提醒背景色",
                    subtitle: "调整提醒面板基础底色。",
                    selection: Binding(
                        get: { settingsStore.backgroundColor.swiftUIColor },
                        set: { settingsStore.backgroundColor = NSColor($0) ?? settingsStore.backgroundColor }
                    ),
                    hex: settingsStore.backgroundColor.hexString
                )

                SettingsSliderRow(
                    title: "背景透明度",
                    subtitle: "控制背景底色透明程度。",
                    value: Binding(
                        get: { settingsStore.backgroundOpacity },
                        set: { settingsStore.backgroundOpacity = $0 }
                    ),
                    range: 0.2...1.0,
                    displayValue: "\(Int((settingsStore.backgroundOpacity * 100).rounded()))%"
                )

                PresetPaletteRow(
                    title: "颜色预设",
                    subtitle: "快速切换一组常用风格。",
                    presets: ReminderColorPreset.morandiPalette,
                    selectedHex: settingsStore.backgroundColor.hexString,
                    showsDivider: false
                ) { preset in
                    settingsStore.applyPreset(preset)
                }
            }
        }
    }
}

private struct AudioSettingsView: View {
    @ObservedObject var settingsStore: SettingsStore

    var body: some View {
        SettingsPage(title: "声音") {
            SettingsGroup {
                SettingsSliderRow(
                    title: "提醒音量",
                    subtitle: "控制点击菜单栏后播放音量。",
                    value: Binding(
                        get: { Double(settingsStore.audioVolume) },
                        set: { settingsStore.audioVolume = Float($0) }
                    ),
                    range: 0...1,
                    displayValue: "\(Int((CGFloat(settingsStore.audioVolume) * 100).rounded()))%"
                )

                ReadOnlyRow(
                    title: "音频文件",
                    subtitle: "默认读取以下文件路径。",
                    value: "Resources/Audio/suanniao.mp3"
                )

                ReadOnlyRow(
                    title: "播放方式",
                    subtitle: "触发时机",
                    value: "点击菜单栏图标时播放"
                )

                ReadOnlyRow(
                    title: "替换说明",
                    subtitle: "保持文件名不变即可热替换。",
                    value: "保持文件名不变即可",
                    showsDivider: false
                )
            }
        }
    }
}

private struct AboutSettingsView: View {
    var body: some View {
        SettingsPage(title: "关于") {
            SettingsGroup {
                ReadOnlyRow(
                    title: "应用名称",
                    subtitle: nil,
                    value: "蒜鸟蒜鸟"
                )

                ReadOnlyRow(
                    title: "版本",
                    subtitle: "当前构建版本。",
                    value: appVersionText
                )

                ReadOnlyRow(
                    title: "平台",
                    subtitle: nil,
                    value: "macOS 14 及以上"
                )

                TextBlockRow(
                    title: "说明",
                    subtitle: "产品理念",
                    text: "“蒜鸟蒜鸟”来自武汉方言里的“算了”。这个应用希望在情绪上头的时候，用更柔和的方式提醒你停一下。",
                    showsDivider: false
                )
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
            VStack(alignment: .leading, spacing: 24) {
                Text(title)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(SettingsUI.primaryText)

                content
            }
            .padding(.horizontal, 32)
            .padding(.top, 30)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
    }
}

private struct SettingsGroup<Content: View>: View {
    let title: String?
    let content: Content

    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title, !title.isEmpty {
                Text(title)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(SettingsUI.primaryText)
                    .padding(.top, 4)
            }

            VStack(spacing: 0) {
                content
            }
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: SettingsUI.groupCorner, style: .continuous)
                    .stroke(SettingsUI.border, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: SettingsUI.groupCorner, style: .continuous))
        }
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
                .padding(.vertical, 16)

            if showsDivider {
                Rectangle()
                    .fill(SettingsUI.separator)
                    .frame(height: 1)
            }
        }
    }
}

private struct SettingLabel: View {
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(SettingsUI.primaryText)

            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(SettingsUI.secondaryText)
            }
        }
    }
}

private struct SettingControlSurface<Content: View>: View {
    let content: Content
    var minWidth: CGFloat? = nil
    var maxWidth: CGFloat? = nil
    var alignment: Alignment = .leading

    init(minWidth: CGFloat? = nil, maxWidth: CGFloat? = nil, alignment: Alignment = .leading, @ViewBuilder content: () -> Content) {
        self.minWidth = minWidth
        self.maxWidth = maxWidth
        self.alignment = alignment
        self.content = content()
    }

    var body: some View {
        content
            .padding(.horizontal, 12)
            .frame(minWidth: minWidth, maxWidth: maxWidth, minHeight: 40, alignment: alignment)
            .background(
                RoundedRectangle(cornerRadius: SettingsUI.controlCorner, style: .continuous)
                    .fill(SettingsUI.rowControlBackground)
            )
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
                SettingLabel(title: title, subtitle: subtitle)

                ReminderPanelContentView(style: style, brandImage: brandImage)
                    .frame(height: 248)
            }
        }
    }
}

private struct SettingsSliderRow<V>: View where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    let title: String
    let subtitle: String?
    let value: Binding<V>
    let range: ClosedRange<V>
    let displayValue: String
    var showsDivider: Bool = true

    var body: some View {
        SettingsRowContainer(showsDivider: showsDivider) {
            HStack(alignment: .center, spacing: 24) {
                SettingLabel(title: title, subtitle: subtitle)

                Spacer(minLength: 20)

                SettingControlSurface(minWidth: 304, alignment: .center) {
                    HStack(spacing: 12) {
                        Slider(value: value, in: range)
                            .frame(width: 204)

                        Text(displayValue)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(SettingsUI.secondaryText)
                            .frame(width: 68, alignment: .trailing)
                    }
                }
            }
        }
    }
}

private struct SettingsToggleRow: View {
    let title: String
    let subtitle: String?
    @Binding var isOn: Bool
    var showsDivider: Bool = true

    var body: some View {
        SettingsRowContainer(showsDivider: showsDivider) {
            HStack {
                SettingLabel(title: title, subtitle: subtitle)

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
    let subtitle: String?
    @Binding var selection: Option
    let options: [Option]
    var showsDivider: Bool = true
    let label: (Option) -> String

    var body: some View {
        SettingsRowContainer(showsDivider: showsDivider) {
            HStack {
                SettingLabel(title: title, subtitle: subtitle)

                Spacer(minLength: 20)

                SettingControlSurface(minWidth: 264, alignment: .center) {
                    Picker(title, selection: $selection) {
                        ForEach(options, id: \.self) { option in
                            Text(label(option)).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                }
            }
        }
    }
}

private struct SettingsColorRow: View {
    let title: String
    let subtitle: String?
    let selection: Binding<Color>
    let hex: String
    var showsDivider: Bool = true

    var body: some View {
        SettingsRowContainer(showsDivider: showsDivider) {
            HStack {
                SettingLabel(title: title, subtitle: subtitle)

                Spacer(minLength: 20)

                SettingControlSurface(minWidth: 180, alignment: .center) {
                    HStack(spacing: 12) {
                        Text(hex)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(SettingsUI.secondaryText)

                        ColorPicker("", selection: selection, supportsOpacity: false)
                            .labelsHidden()
                    }
                }
            }
        }
    }
}

private struct PresetPaletteRow: View {
    let title: String
    let subtitle: String?
    let presets: [ReminderColorPreset]
    let selectedHex: String
    var showsDivider: Bool = false
    let action: (ReminderColorPreset) -> Void

    var body: some View {
        SettingsRowContainer(showsDivider: showsDivider) {
            HStack(alignment: .top, spacing: 20) {
                SettingLabel(title: title, subtitle: subtitle)
                    .padding(.top, 2)

                Spacer(minLength: 20)

                SettingControlSurface(minWidth: 174, alignment: .center) {
                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(40), spacing: 8), count: 3), spacing: 8) {
                        ForEach(presets) { preset in
                            let isSelected = preset.color.hexString == selectedHex

                            Button {
                                action(preset)
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(preset.color.swiftUIColor)

                                    Text("蒜")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundStyle(preset.textColor.swiftUIColor)
                                }
                                .frame(width: 40, height: 40)
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
}

private struct ReadOnlyRow: View {
    let title: String
    let subtitle: String?
    let value: String
    var showsDivider: Bool = true

    var body: some View {
        SettingsRowContainer(showsDivider: showsDivider) {
            HStack(spacing: 18) {
                SettingLabel(title: title, subtitle: subtitle)

                Spacer(minLength: 16)

                SettingControlSurface(minWidth: 264, maxWidth: 328, alignment: .trailing) {
                    Text(value)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(SettingsUI.secondaryText)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
        }
    }
}

private struct TextBlockRow: View {
    let title: String
    let subtitle: String?
    let text: String
    var showsDivider: Bool = false

    var body: some View {
        SettingsRowContainer(showsDivider: showsDivider) {
            HStack(alignment: .top, spacing: 20) {
                SettingLabel(title: title, subtitle: subtitle)
                    .padding(.top, 2)

                Spacer(minLength: 20)

                Text(text)
                    .font(.system(size: 14))
                    .foregroundStyle(SettingsUI.secondaryText)
                    .multilineTextAlignment(.leading)
                    .frame(width: 360, alignment: .leading)
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
