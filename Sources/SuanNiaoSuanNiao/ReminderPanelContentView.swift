import SwiftUI

struct ReminderPanelContentView: View {
    let style: ReminderStyle
    let brandImage: NSImage?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    style.backgroundColor.swiftUIColor.opacity(0.26),
                    style.backgroundColor.blended(withFraction: 0.28, of: .white)?.swiftUIColor.opacity(0.22) ?? .white.opacity(0.22),
                    Color.white.opacity(0.18)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(style.backgroundColor.swiftUIColor.opacity(style.backgroundOpacity))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(Color.white.opacity(0.42), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.14), radius: 28, x: 0, y: 14)
                .padding(18)

            VStack(spacing: style.showIcon ? 24 : 0) {
                if style.showIcon, let brandImage {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.16))
                            .frame(width: 88, height: 88)
                            .background(.ultraThinMaterial, in: Circle())

                        Image(nsImage: brandImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 52, height: 52)
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
}
