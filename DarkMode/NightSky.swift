//
//  NightSky.swift
//  DarkMode
//

import SwiftUI

extension Color {
    /// Near-black app background (#0F0F0F).
    static let nightBackground = Color(red: 15 / 255, green: 15 / 255, blue: 15 / 255)
}

/// A simple flat crescent moon.
struct HalfMoon: View {
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(Color.white)
            .mask {
                // Cut away an offset circle to leave a crescent.
                Rectangle()
                    .overlay {
                        Circle()
                            .frame(width: size * 0.92, height: size * 0.92)
                            .offset(x: size * 0.17, y: -size * 0.11)
                            .blendMode(.destinationOut)
                    }
                    .compositingGroup()
            }
            .frame(width: size, height: size)
            .accessibilityHidden(true)
    }
}

#Preview {
    ZStack {
        Color.nightBackground
        HalfMoon(size: 120)
    }
    .ignoresSafeArea()
}
