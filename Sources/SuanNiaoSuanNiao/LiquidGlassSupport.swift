import SwiftUI

struct LiquidGlassContainer<Content: View>: View {
    private let spacing: CGFloat
    private let content: Content

    init(spacing: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        if #available(macOS 26.0, iOS 26.0, *) {
            GlassEffectContainer(spacing: spacing) {
                content
            }
        } else {
            content
        }
    }
}

extension View {
    @ViewBuilder
    func liquidGlass(
        in shape: AnyShape,
        isEnabled: Bool = true,
        fallbackMaterial: Material? = .thinMaterial,
        fallbackTint: Color = Color.white.opacity(0.08)
    ) -> some View {
        if #available(macOS 26.0, iOS 26.0, *), isEnabled {
            self.glassEffect(in: shape)
        } else if isEnabled {
            modifier(
                LiquidGlassFallbackModifier(
                    shape: shape,
                    material: fallbackMaterial,
                    tint: fallbackTint
                )
            )
        } else {
            self
        }
    }

    func liquidGlassCard(
        cornerRadius: CGFloat,
        isEnabled: Bool = true,
        fallbackMaterial: Material? = .thinMaterial,
        fallbackTint: Color = Color.white.opacity(0.08)
    ) -> some View {
        liquidGlass(
            in: AnyShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)),
            isEnabled: isEnabled,
            fallbackMaterial: fallbackMaterial,
            fallbackTint: fallbackTint
        )
    }
}

private struct LiquidGlassFallbackModifier: ViewModifier {
    let shape: AnyShape
    let material: Material?
    let tint: Color

    @ViewBuilder
    func body(content: Content) -> some View {
        if let material {
            content
                .background(material, in: shape)
                .overlay(shape.fill(tint))
        } else {
            content.overlay(shape.fill(tint))
        }
    }
}
