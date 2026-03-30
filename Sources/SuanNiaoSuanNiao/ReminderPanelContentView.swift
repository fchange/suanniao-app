import SwiftUI

struct ReminderPanelContentView: View {
    let style: ReminderStyle
    let brandImage: NSImage?

    private let panelCornerRadius: CGFloat = 34
    private let iconBadgeSize: CGFloat = 104
    private let iconImageSize: CGFloat = 74

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(panelBaseGradient)
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(materialOverlay)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(tintedOverlay)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(highlightOverlay)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(borderOverlay, lineWidth: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(Color.white.opacity(style.glassMode == .off ? 0.08 : 0.18), lineWidth: 10)
                        .blur(radius: style.glassMode == .off ? 0 : 18)
                        .mask(
                            RoundedRectangle(cornerRadius: 34, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [.white, .white.opacity(0)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                )
                .shadow(color: Color.black.opacity(0.14), radius: 28, x: 0, y: 14)
                .padding(18)

            VStack(spacing: style.showIcon ? 24 : 0) {
                if style.showIcon, let brandImage {
                    ZStack {
                        Circle()
                            .fill(iconBadgeTint)
                            .frame(width: iconBadgeSize, height: iconBadgeSize)
                            .background(iconBadgeMaterial, in: Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(style.glassMode == .off ? 0.14 : 0.42), lineWidth: 1)
                            )

                        Image(nsImage: brandImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: iconImageSize, height: iconImageSize)
                            .scaleEffect(1.06)
                    }
                    .padding(.top, 22)
                }

                Text("蒜鸟蒜鸟")
                    .font(.system(size: style.fontSize, weight: .bold, design: .rounded))
                    .foregroundStyle(style.textColor.swiftUIColor.opacity(style.textOpacity))
                    .minimumScaleFactor(0.75)
                    .lineLimit(1)
                    .padding(.horizontal, 28)
                    .padding(.bottom, style.showIcon ? 18 : 0)
            }
            .padding(32)
        }
        .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
    }

    private var panelBaseGradient: LinearGradient {
        LinearGradient(
            colors: [
                style.backgroundColor.blended(withFraction: 0.42, of: .white)?.swiftUIColor.opacity(0.40) ?? .white.opacity(0.40),
                style.backgroundColor.swiftUIColor.opacity(0.24),
                Color.white.opacity(style.glassMode == .off ? 0.06 : 0.14)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var materialOverlay: AnyShapeStyle {
        switch style.glassMode {
        case .off:
            return AnyShapeStyle(Color.clear)
        case .soft:
            return AnyShapeStyle(.thinMaterial)
        case .vivid:
            return AnyShapeStyle(.regularMaterial)
        }
    }

    private var tintedOverlay: Color {
        let opacity: CGFloat

        switch style.glassMode {
        case .off:
            opacity = max(style.backgroundOpacity, 0.88)
        case .soft:
            opacity = style.backgroundOpacity * 0.78
        case .vivid:
            opacity = style.backgroundOpacity * 0.64
        }

        return style.backgroundColor.swiftUIColor.opacity(opacity)
    }

    private var highlightOverlay: LinearGradient {
        LinearGradient(
            colors: [
                Color.white.opacity(style.glassMode == .off ? 0.02 : 0.24),
                Color.white.opacity(style.glassMode == .off ? 0.01 : 0.08),
                Color.clear
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var borderOverlay: Color {
        switch style.glassMode {
        case .off:
            return Color.white.opacity(0.16)
        case .soft:
            return Color.white.opacity(0.32)
        case .vivid:
            return Color.white.opacity(0.46)
        }
    }

    private var iconBadgeTint: Color {
        switch style.glassMode {
        case .off:
            return Color.white.opacity(0.08)
        case .soft:
            return Color.white.opacity(0.12)
        case .vivid:
            return Color.white.opacity(0.16)
        }
    }

    private var iconBadgeMaterial: AnyShapeStyle {
        switch style.glassMode {
        case .off:
            return AnyShapeStyle(Color.clear)
        case .soft:
            return AnyShapeStyle(.ultraThinMaterial)
        case .vivid:
            return AnyShapeStyle(.thinMaterial)
        }
    }
}
