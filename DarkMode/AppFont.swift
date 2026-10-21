//
//  AppFont.swift
//  DarkMode
//

import SwiftUI

extension Font {
    /// The bundled Google Sans Flex variable font, registered via `UIAppFonts`.
    private static let googleSansFamily = "Google Sans Flex"

    /// Google Sans Flex at the size of the given text style, scaling with Dynamic Type.
    static func googleSans(_ style: TextStyle, weight: Weight = .regular) -> Font {
        googleSans(size: style.defaultPointSize, relativeTo: style, weight: weight)
    }

    /// Google Sans Flex at a custom size that scales like the given text style.
    static func googleSans(size: CGFloat, relativeTo style: TextStyle, weight: Weight = .regular) -> Font {
        .custom(googleSansFamily, size: size, relativeTo: style)
            .weight(weight)
    }
}

private extension Font.TextStyle {
    /// Point sizes of each text style at the default (Large) Dynamic Type setting.
    var defaultPointSize: CGFloat {
        switch self {
        case .extraLargeTitle2: 28
        case .extraLargeTitle: 36
        case .largeTitle: 34
        case .title: 28
        case .title2: 22
        case .title3: 20
        case .headline: 17
        case .body: 17
        case .callout: 16
        case .subheadline: 15
        case .footnote: 13
        case .caption: 12
        case .caption2: 11
        @unknown default: 17
        }
    }
}
