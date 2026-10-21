//
//  BeforeAfterDemo.swift
//  DarkMode
//

import SwiftUI

/// An interactive comparison of a mock webpage before and after the extension
/// darkens it. Drag anywhere on the card to move the divider.
struct BeforeAfterDemo: View {
    /// Fraction of the card's width that shows the original (light) page.
    /// Starts fully on the original light page.
    @State private var split: CGFloat = 0.96

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width

            ZStack(alignment: .leading) {
                MockWebPage(isDark: false, headline: "Why is it light?")
                MockWebPage(isDark: true, headline: "What a lovely website!")
                    .mask(alignment: .trailing) {
                        Rectangle().frame(width: width * (1 - split))
                    }

                DividerHandle()
                    .offset(x: width * split - DividerHandle.size / 2)
            }
            // Pin to the card's size so the mock page can't spill past its edges.
            .frame(width: width, height: proxy.size.height, alignment: .top)
            .overlay(alignment: .topLeading) { CornerLabel(text: "Before", color: Color(white: 0.35)).opacity(split > 0.2 ? 1 : 0) }
            .overlay(alignment: .topTrailing) { CornerLabel(text: "After", color: Color(white: 0.75)).opacity(split < 0.8 ? 1 : 0) }
            .clipShape(.rect(cornerRadius: 24))
            .contentShape(.rect(cornerRadius: 24))
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        split = min(max(value.location.x / width, 0.04), 0.96)
                    }
            )
        }
        .frame(height: 330)
        .overlay {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(.white.opacity(0.15))
        }
        .accessibilityElement()
        .accessibilityLabel("Before and after preview of a darkened website")
        .accessibilityValue("\(Int((1 - split) * 100)) percent dark")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: split = max(split - 0.1, 0.04)
            case .decrement: split = min(split + 0.1, 0.96)
            @unknown default: break
            }
        }
    }
}

/// The draggable divider between the two halves.
private struct DividerHandle: View {
    static let size: CGFloat = 44

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .frame(width: 3)

            Image(systemName: "chevron.left.chevron.right")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: Self.size, height: Self.size)
                .glassEffect(.regular.interactive(), in: .circle)
        }
        .frame(width: Self.size)
        .frame(maxHeight: .infinity)
    }
}

private struct CornerLabel: View {
    let text: LocalizedStringKey
    let color: Color

    var body: some View {
        Text(text)
            .font(.googleSans(.caption, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .padding(10)
    }
}

/// A stylised news site used as decoration in the demo. Uses fixed sizes
/// because it's an illustration rather than readable content.
private struct MockWebPage: View {
    let isDark: Bool
    /// Each version of the page has its own fixed headline, revealed by the divider.
    let headline: LocalizedStringKey

    private let ink = Color(white: 0.12)
    private let rule = Color(white: 0.84)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 5) {
                Image(systemName: "lock.fill")
                Text(verbatim: "eveningpaper.com")
            }
            .font(.system(size: 11))
            .foregroundStyle(Color(white: 0.4))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(Color(white: 0.93), in: .capsule)

            Text(headline)
                .font(.system(size: 22, weight: .bold, design: .serif))
                .foregroundStyle(ink)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            HStack(alignment: .top, spacing: 12) {
                SunsetPhoto()
                    .frame(width: 112, height: 92)
                    .clipShape(.rect(cornerRadius: 10))
                    // Undo the page inversion so the photo keeps its real colors,
                    // exactly like the extension does for <img> elements.
                    .forcedDark(isDark)

                VStack(alignment: .leading, spacing: 8) {
                    Text(verbatim: "Stargazing season is here")
                        .font(.system(size: 13, weight: .semibold, design: .serif))
                        .foregroundStyle(ink)
                    line(trailing: 0)
                    line(trailing: 12)
                    line(trailing: 0)
                    line(trailing: 30)
                }
            }

            line(trailing: 0)
            line(trailing: 24)
            line(trailing: 60)

            HStack(spacing: 8) {
                Capsule().fill(Color(red: 0.15, green: 0.45, blue: 0.95)).frame(width: 70, height: 22)
                Capsule().strokeBorder(rule, lineWidth: 1.5).frame(width: 56, height: 22)
            }
        }
        .padding(16)
        .padding(.top, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.white)
        .forcedDark(isDark)
        .accessibilityHidden(true)
    }

    private func line(trailing: CGFloat) -> some View {
        Capsule()
            .fill(rule)
            .frame(height: 6)
            .padding(.trailing, trailing)
    }
}

/// A tiny illustrated sunset to stand in for a photo.
private struct SunsetPhoto: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.62, blue: 0.30),
                    Color(red: 0.95, green: 0.38, blue: 0.48),
                    Color(red: 0.45, green: 0.30, blue: 0.75),
                ],
                startPoint: .bottom,
                endPoint: .top
            )
            Circle()
                .fill(Color(red: 1.0, green: 0.88, blue: 0.45))
                .frame(width: 30, height: 30)
                .offset(x: 18, y: -26)
            Mountains()
                .fill(Color(red: 0.20, green: 0.14, blue: 0.36))
                .frame(height: 44)
        }
    }
}

private struct Mountains: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.height * 0.55))
            path.addLine(to: CGPoint(x: rect.width * 0.28, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.width * 0.5, y: rect.height * 0.5))
            path.addLine(to: CGPoint(x: rect.width * 0.7, y: rect.height * 0.2))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.height * 0.65))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

private extension View {
    /// Mirrors the extension's CSS: `filter: invert(1) hue-rotate(180deg)`.
    /// Applying it twice restores the original colors.
    @ViewBuilder
    func forcedDark(_ isOn: Bool) -> some View {
        if isOn {
            colorInvert().hueRotation(.degrees(180))
        } else {
            self
        }
    }
}

#Preview {
    BeforeAfterDemo()
        .padding()
        .background(.black)
}
