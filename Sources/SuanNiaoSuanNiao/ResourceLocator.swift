import AppKit
import Foundation

enum ResourceLocator {
    static func audioFileURL() -> URL? {
        let candidates = [
            ("Audio/suanniao", "mp3"),
            ("Audio/suanniao", "m4a")
        ]

        for (name, ext) in candidates {
            if let url = url(named: name, withExtension: ext) {
                return url
            }
        }

        return nil
    }

    static func statusBarImage() -> NSImage? {
        loadImage(
            candidates: [
                ("BrandMarkFilledCutout", "pdf"),
                ("BrandMarkFilledCutout", "png"),
                ("BrandMarkOutline", "pdf"),
                ("BrandMarkOutline", "png"),
                ("StatusBarIcon", "pdf"),
                ("StatusBarIcon", "png"),
                ("BrandMarkGradient", "pdf"),
                ("BrandMarkGradient", "png")
            ],
            template: false,
            size: NSSize(width: 18, height: 18)
        )
    }

    static func brandImage() -> NSImage? {
        loadImage(
            candidates: [
                ("BrandMarkGradient", "pdf"),
                ("BrandMarkGradient", "png"),
                ("BrandMarkOutline", "pdf"),
                ("BrandMarkOutline", "png"),
                ("StatusBarIcon", "pdf"),
                ("StatusBarIcon", "png"),
                ("BrandMarkFilledCutout", "png")
            ],
            template: false,
            size: nil
        )
    }

    static func url(named name: String, withExtension ext: String) -> URL? {
        if let mainBundleURL = Bundle.main.url(forResource: name, withExtension: ext) {
            return mainBundleURL
        }

        let relativePath = "\(name).\(ext)"
        let fileManager = FileManager.default
        let workingDirectory = fileManager.currentDirectoryPath
        let candidates = [
            URL(fileURLWithPath: workingDirectory).appendingPathComponent("Resources/\(relativePath)"),
            URL(fileURLWithPath: workingDirectory).appendingPathComponent(relativePath)
        ]

        return candidates.first(where: { fileManager.fileExists(atPath: $0.path) })
    }

    private static func loadImage(
        candidates: [(String, String)],
        template: Bool,
        size: NSSize?
    ) -> NSImage? {
        for (name, ext) in candidates {
            if let url = url(named: name, withExtension: ext),
               let image = NSImage(contentsOf: url) {
                image.isTemplate = template
                if let size {
                    image.size = size
                }
                return image
            }
        }

        return nil
    }
}
