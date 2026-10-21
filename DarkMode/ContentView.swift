//
//  ContentView.swift
//  DarkMode
//

import SwiftUI
import SafariServices

struct ContentView: View {
    /// Bundle identifier of the embedded Safari web extension.
    private let extensionIdentifier = "first.DarkMode.DarkModeExtension"

    @State private var openSettingsError: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                hero

                VStack(alignment: .leading, spacing: 14) {
                    SectionHeader(title: "See the difference")
                    BeforeAfterDemo()
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text("Good to know")
                        .font(.googleSans(.title2, weight: .bold))
                        .foregroundStyle(.white)
                        .accessibilityAddTraits(.isHeader)
                    TipRow(
                        systemImage: "puzzlepiece.extension.fill",
                        text: "Tap the extensions button in Safari’s address bar to pause Dusk for one site or dim the brightness."
                    )
                    TipRow(
                        systemImage: "sparkles",
                        text: "Sites that already have a dark theme are detected and left untouched."
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 12)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
            .frame(maxWidth: 560)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .background(Color.nightBackground)
        .safeAreaInset(edge: .bottom) {
            Button(action: openExtensionSettings) {
                Label("Open Safari Settings", systemImage: "safari.fill")
                    .font(.googleSans(.headline, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
                    .foregroundStyle(.white)
            }
            .buttonStyle(.glass)
            .controlSize(.large)
            .frame(maxWidth: 560)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .preferredColorScheme(.dark)
        .alert("Couldn’t Open Settings", isPresented: Binding(
            get: { openSettingsError != nil },
            set: { if !$0 { openSettingsError = nil } }
        )) {
            Button("OK") {}
        } message: {
            Text(openSettingsError ?? "")
        }
    }

    private var hero: some View {
        VStack(spacing: 24) {
            HalfMoon(size: 110)
                .padding(.top, 24)

            VStack(spacing: 8) {
                Text("Dusk")
                    .font(.googleSans(size: 56, relativeTo: .largeTitle, weight: .bold))
                    .tracking(-1)
                    .foregroundStyle(.white)
                Text("Every website, after sunset.")
                    .font(.googleSans(.title3))
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
        }
    }

    private func openExtensionSettings() {
        SFSafariSettings.openExtensionsSettings(forIdentifiers: [extensionIdentifier]) { error in
            if let error {
                openSettingsError = "Open the Settings app, then go to Apps › Safari › Extensions. (\(error.localizedDescription))"
            }
        }
    }
}

/// A small, letter-spaced section title.
private struct SectionHeader: View {
    let title: LocalizedStringKey

    var body: some View {
        Text(title)
            .font(.googleSans(.caption, weight: .semibold))
            .textCase(.uppercase)
            .tracking(2)
            .foregroundStyle(Color.white)
            .accessibilityAddTraits(.isHeader)
    }
}

private struct TipRow: View {
    let systemImage: String
    let text: LocalizedStringKey

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(Color.white)
            Text(text)
                .font(.googleSans(.subheadline))
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ContentView()
}
