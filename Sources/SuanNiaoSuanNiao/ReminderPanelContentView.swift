import AppKit
import SwiftUI

struct ReminderPanelContentView: View {
    let style: ReminderStyle
    let brandImage: NSImage?

    private let panelCornerRadius: CGFloat = 34

    var body: some View {
        ZStack {
            if style.glassMode != .clear {
                panelSurface
            }

            ReminderPanelBody(
                style: style,
                brandImage: brandImage
            )
        }
        .padding(style.glassMode == .clear ? 8 : 20)
        .clipShape(RoundedRectangle(cornerRadius: panelCornerRadius + 2, style: .continuous))
    }

    private var panelSurface: some View {
        let shape = RoundedRectangle(cornerRadius: panelCornerRadius, style: .continuous)

        return RoundedRectangle(cornerRadius: panelCornerRadius, style: .continuous)
            .fill(panelTintLayer)
            .background(panelFrostLayer, in: shape)
            .overlay(
                shape
                    .fill(matteOverlay)
            )
            .overlay(
                shape
                    .stroke(borderOverlay, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.14), radius: 28, x: 0, y: 14)
    }

    private var panelTintLayer: Color {
        style.backgroundColor.swiftUIColor.opacity(panelTintOpacity)
    }

    private var panelTintOpacity: CGFloat {
        switch style.glassMode {
        case .clear:
            return 0
        case .off:
            return max(style.backgroundOpacity, 0.90)
        case .soft:
            return max(style.backgroundOpacity * 0.68, 0.48)
        case .vivid:
            return max(style.backgroundOpacity * 0.58, 0.42)
        }
    }

    private var panelFrostLayer: AnyShapeStyle {
        switch style.glassMode {
        case .clear:
            return AnyShapeStyle(Color.clear)
        case .off:
            return AnyShapeStyle(Color.clear)
        case .soft:
            return AnyShapeStyle(.thinMaterial)
        case .vivid:
            return AnyShapeStyle(.regularMaterial)
        }
    }

    private var matteOverlay: LinearGradient {
        if style.glassMode == .clear {
            return LinearGradient(colors: [.clear, .clear], startPoint: .top, endPoint: .bottom)
        }

        return LinearGradient(
            colors: [
                Color.white.opacity(style.glassMode == .off ? 0.05 : 0.12),
                Color.white.opacity(style.glassMode == .off ? 0.02 : 0.06),
                Color.black.opacity(style.glassMode == .off ? 0.02 : 0.09)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var borderOverlay: Color {
        switch style.glassMode {
        case .clear:
            return .clear
        case .off:
            return Color.white.opacity(0.16)
        case .soft:
            return Color.white.opacity(0.22)
        case .vivid:
            return Color.white.opacity(0.28)
        }
    }
}

private struct ReminderPanelBody: View {
    let style: ReminderStyle
    let brandImage: NSImage?

    var body: some View {
        VStack(spacing: style.showIcon ? 24 : 0) {
            if style.showIcon, let brandImage {
                ReminderIconBadge(
                    glassMode: style.glassMode,
                    brandImage: brandImage
                )
                .padding(.top, 20)
            }

            Text("蒜鸟蒜鸟")
                .font(.system(size: style.fontSize, weight: .bold, design: .rounded))
                .foregroundStyle(style.textColor.swiftUIColor.opacity(style.textOpacity))
                .minimumScaleFactor(0.75)
                .lineLimit(1)
                .shadow(color: Color.black.opacity(style.glassMode == .clear ? 0.24 : 0.16), radius: 1.2, x: 0, y: 1)
                .padding(.horizontal, 28)
                .padding(.bottom, style.showIcon ? 16 : 2)
        }
        .padding(32)
    }
}

private struct ReminderIconBadge: View {
    let glassMode: ReminderGlassMode
    let brandImage: NSImage

    private let badgeSize: CGFloat = 104
    private let imageSize: CGFloat = 74

    var body: some View {
        ZStack {
            Circle()
                .fill(iconBadgeTint)
                .frame(width: badgeSize, height: badgeSize)
                .background(iconBadgeMaterial, in: Circle())
                .overlay(
                    Circle().stroke(
                        iconBorderColor,
                        lineWidth: 1
                    )
                )

            Image(nsImage: brandImage)
                .resizable()
                .scaledToFit()
                .frame(width: imageSize, height: imageSize)
                .scaleEffect(1.06)
        }
    }

    private var iconBadgeTint: Color {
        switch glassMode {
        case .clear:
            return Color.white.opacity(0.16)
        case .off:
            return Color.white.opacity(0.08)
        case .soft:
            return Color.white.opacity(0.12)
        case .vivid:
            return Color.white.opacity(0.17)
        }
    }

    private var iconBadgeMaterial: AnyShapeStyle {
        switch glassMode {
        case .clear:
            return AnyShapeStyle(.ultraThinMaterial)
        case .off:
            return AnyShapeStyle(Color.clear)
        case .soft:
            return AnyShapeStyle(.thinMaterial)
        case .vivid:
            return AnyShapeStyle(.regularMaterial)
        }
    }

    private var iconBorderColor: Color {
        switch glassMode {
        case .clear:
            return Color.white.opacity(0.30)
        case .off:
            return Color.white.opacity(0.12)
        case .soft, .vivid:
            return Color.white.opacity(0.36)
        }
    }
}
