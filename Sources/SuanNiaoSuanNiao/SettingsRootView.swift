import SwiftUI

struct SettingsRootView: View {
    @ObservedObject var settingsStore: SettingsStore
    @ObservedObject var selection: SectionSelection

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.93, blue: 0.90),
                    Color(red: 0.92, green: 0.96, blue: 1.0),
                    Color(red: 0.94, green: 0.93, blue: 0.99)
                ],
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )
            .ignoresSafeArea()

            RoundedRectangle(cornerRadius: 36, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .stroke(Color.white.opacity(0.55), lineWidth: 1)
                )
                .padding(22)

            HStack(spacing: 0) {
                sidebar
                    .frame(width: 260)

                Divider()
                    .overlay(Color.black.opacity(0.05))

                detail
            }
            .padding(22)
        }
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(.regularMaterial)
                        .frame(width: 76, height: 76)

                    if let image = ResourceLocator.brandImage() {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44, height: 44)
                    } else {
                        Image(systemName: "bird")
                            .font(.system(size: 28, weight: .semibold))
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("蒜鸟蒜鸟")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                    Text("放一放，莫上头。")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 18)

            VStack(spacing: 10) {
                sidebarButton(for: .appearance, icon: "wand.and.stars")
                sidebarButton(for: .audio, icon: "speaker.wave.2")
                sidebarButton(for: .about, icon: "heart.text.square")
            }
            .padding(.horizontal, 14)

            Spacer()
        }
    }

    private var detail: some View {
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
    }

    private func sidebarButton(for section: SettingsWindowController.Section, icon: String) -> some View {
        Button {
            selection.section = section
        } label: {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 24)
                Text(section.title)
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
            }
            .foregroundStyle(Color.primary)
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(selection.section == section ? Color.white.opacity(0.74) : .clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(selection.section == section ? Color.white.opacity(0.7) : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct AppearanceSettingsView: View {
    @ObservedObject var settingsStore: SettingsStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header(title: "提醒外观", subtitle: "重写弹窗视觉，并把控制项集中到这里。")

                previewCard

                settingsCard {
                    settingRow(
                        title: "提醒显示图标",
                        subtitle: "打开后在提醒浮窗里展示品牌图标。"
                    ) {
                        Toggle("", isOn: $settingsStore.showReminderIcon)
                            .labelsHidden()
                            .toggleStyle(.switch)
                    }

                    settingRow(
                        title: "提醒窗口大小",
                        subtitle: "调节整体卡片比例，不改变文字内容。"
                    ) {
                        VStack(alignment: .trailing, spacing: 8) {
                            Slider(
                                value: Binding(
                                    get: { settingsStore.windowScale },
                                    set: { settingsStore.windowScale = $0 }
                                ),
                                in: 0.8...1.55
                            )
                            .frame(width: 240)

                            Text("\(Int((settingsStore.windowScale * 100).rounded()))%")
                                .font(.system(.footnote, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }

                    settingRow(
                        title: "字体大小",
                        subtitle: "控制“蒜鸟蒜鸟”的主视觉尺寸。"
                    ) {
                        VStack(alignment: .trailing, spacing: 8) {
                            Slider(
                                value: Binding(
                                    get: { settingsStore.fontSize },
                                    set: { settingsStore.fontSize = $0 }
                                ),
                                in: 44...108
                            )
                            .frame(width: 240)

                            Text("\(Int(settingsStore.fontSize.rounded())) pt")
                                .font(.system(.footnote, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }

                    settingRow(
                        title: "文字透明度",
                        subtitle: "让提醒更通透，或者更醒目。"
                    ) {
                        VStack(alignment: .trailing, spacing: 8) {
                            Slider(
                                value: Binding(
                                    get: { settingsStore.textOpacity },
                                    set: { settingsStore.textOpacity = $0 }
                                ),
                                in: 0.25...1.0
                            )
                            .frame(width: 240)

                            Text("\(Int((settingsStore.textOpacity * 100).rounded()))%")
                                .font(.system(.footnote, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }

                    settingRow(
                        title: "文字颜色",
                        subtitle: "建议保留偏暖白，整体更轻。"
                    ) {
                        VStack(alignment: .trailing, spacing: 8) {
                            ColorPicker(
                                "",
                                selection: Binding(
                                    get: { settingsStore.textColor.swiftUIColor },
                                    set: { settingsStore.textColor = NSColor($0) ?? settingsStore.textColor }
                                ),
                                supportsOpacity: false
                            )
                            .labelsHidden()

                            Text(settingsStore.textColor.hexString)
                                .font(.system(.footnote, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }

                    settingRow(
                        title: "提醒背景色",
                        subtitle: "控制弹窗卡片底色。"
                    ) {
                        VStack(alignment: .trailing, spacing: 8) {
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
                                .font(.system(.footnote, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }

                    settingRow(
                        title: "背景透明度",
                        subtitle: "决定背景色覆盖玻璃材质的程度。"
                    ) {
                        VStack(alignment: .trailing, spacing: 8) {
                            Slider(
                                value: Binding(
                                    get: { settingsStore.backgroundOpacity },
                                    set: { settingsStore.backgroundOpacity = $0 }
                                ),
                                in: 0.2...1.0
                            )
                            .frame(width: 240)

                            Text("\(Int((settingsStore.backgroundOpacity * 100).rounded()))%")
                                .font(.system(.footnote, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                presetCard
            }
            .padding(.horizontal, 34)
            .padding(.vertical, 28)
        }
        .scrollIndicators(.hidden)
    }

    private var previewCard: some View {
        settingsSectionCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("实时预览")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)

                ReminderPanelContentView(
                    style: settingsStore.reminderStyle,
                    brandImage: ResourceLocator.brandImage()
                )
                .frame(height: 260)
            }
        }
    }

    private var presetCard: some View {
        settingsSectionCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("莫兰迪预设")
                    .font(.system(size: 18, weight: .semibold))

                Text("快速切换一组更柔和的背景色。")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                    ForEach(ReminderColorPreset.morandiPalette) { preset in
                        Button {
                            settingsStore.applyPreset(preset)
                        } label: {
                            HStack(spacing: 12) {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(preset.color.swiftUIColor)
                                    .frame(width: 34, height: 34)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(Color.white.opacity(0.6), lineWidth: 1)
                                    )

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(preset.name)
                                        .font(.system(size: 15, weight: .semibold))
                                    Text(preset.color.hexString)
                                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()
                            }
                            .padding(14)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(Color.white.opacity(0.52))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct AudioSettingsView: View {
    @ObservedObject var settingsStore: SettingsStore

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header(title: "声音", subtitle: "控制点击菜单栏后的语音提醒。")

            settingsSectionCard {
                VStack(alignment: .leading, spacing: 0) {
                    settingRow(
                        title: "音频音量",
                        subtitle: "再次点击时会停止旧播放，并从头开始。"
                    ) {
                        VStack(alignment: .trailing, spacing: 8) {
                            Slider(
                                value: Binding(
                                    get: { Double(settingsStore.audioVolume) },
                                    set: { settingsStore.audioVolume = Float($0) }
                                ),
                                in: 0...1
                            )
                            .frame(width: 240)

                            Text("\(Int((CGFloat(settingsStore.audioVolume) * 100).rounded()))%")
                                .font(.system(.footnote, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            settingsSectionCard {
                VStack(alignment: .leading, spacing: 10) {
                    Text("当前资源")
                        .font(.system(size: 18, weight: .semibold))
                    Text("播放文件路径约定为 `Resources/Audio/suanniao.mp3`。缺失时会优雅降级，不会崩溃。")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 34)
        .padding(.vertical, 28)
    }
}

private struct AboutSettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header(title: "关于『蒜鸟蒜鸟』", subtitle: "一只来自武汉方言文化的小提醒。")

            settingsSectionCard {
                HStack(alignment: .top, spacing: 22) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(.regularMaterial)
                            .frame(width: 96, height: 96)

                        if let image = ResourceLocator.brandImage() {
                            Image(nsImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 58, height: 58)
                        } else {
                            Image(systemName: "bird")
                                .font(.system(size: 34, weight: .semibold))
                        }
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("蒜鸟蒜鸟")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                        Text("“蒜鸟”来自武汉方言里的“算了”，像一句带着分寸感的安抚：别争了，先放下，莫上头。")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                        Text("这些年它也慢慢成了网络热词，带着一点武汉文化气质，也带着一点松弛和治愈。")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, 34)
        .padding(.vertical, 28)
    }
}

private func header(title: String, subtitle: String) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        Text(title)
            .font(.system(size: 42, weight: .bold, design: .rounded))
        Text(subtitle)
            .font(.system(size: 16))
            .foregroundStyle(.secondary)
    }
}

private func settingsSectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 0) {
        content()
    }
    .padding(24)
    .background(
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(.regularMaterial)
    )
    .overlay(
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .stroke(Color.white.opacity(0.55), lineWidth: 1)
    )
}

private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
    settingsSectionCard {
        VStack(spacing: 0) {
            content()
        }
    }
}

private func settingRow<Accessory: View>(
    title: String,
    subtitle: String,
    @ViewBuilder accessory: () -> Accessory
) -> some View {
    HStack(alignment: .center, spacing: 20) {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
            Text(subtitle)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
        }

        Spacer(minLength: 24)
        accessory()
    }
    .padding(.vertical, 18)
    .overlay(alignment: .bottom) {
        Divider()
            .opacity(0.5)
    }
}

private extension NSColor {
    convenience init?(_ color: Color) {
        guard let cgColor = color.cgColor else { return nil }
        self.init(cgColor: cgColor)
    }
}
