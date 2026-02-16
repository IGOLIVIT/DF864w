//
//  SettingsView.swift
//  DF864w
//

import SwiftUI

struct SettingsView: View {
    @Bindable var settings: SettingsStore
    let cacheManager: CacheManaging
    @State private var storageBytes: Int64 = 0
    @State private var showClearAlert = false
    @State private var clearDone = false

    var body: some View {
        NavigationStack {
            List {
                Section("Appearance") {
                    Picker("Theme", selection: Binding(
                        get: { settings.appTheme },
                        set: { settings.appTheme = $0 }
                    )) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                }

                Section("Export defaults") {
                    Picker("Format", selection: Binding(
                        get: { settings.defaultExportFormat },
                        set: { settings.defaultExportFormat = $0 }
                    )) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    Picker("Size", selection: Binding(
                        get: { settings.defaultExportResolution },
                        set: { settings.defaultExportResolution = $0 }
                    )) {
                        ForEach(ExportResolution.allCases, id: \.self) { res in
                            Text(res.rawValue).tag(res)
                        }
                    }
                    VStack(alignment: .leading) {
                        Text("JPEG quality: \(Int(settings.jpegQuality * 100))%")
                            .font(.subheadline)
                        Slider(value: Binding(
                            get: { settings.jpegQuality },
                            set: { settings.jpegQuality = $0 }
                        ), in: 0.5...1, step: 0.05)
                        .tint(Theme.Colors.accent)
                    }
                }

                Section("Performance") {
                    Toggle("Performance mode", isOn: $settings.performanceMode)
                        .tint(Theme.Colors.accent)
                    Text("Uses lower preview resolution for smoother controls on older devices.")
                        .font(.caption)
                        .foregroundStyle(Theme.Colors.secondaryText)
                }

                Section("Feedback") {
                    Toggle("Haptics", isOn: $settings.hapticsEnabled)
                        .tint(Theme.Colors.accent)
                }

                Section("Storage") {
                    HStack {
                        Text("Exported images")
                        Spacer()
                        Text(formatBytes(storageBytes))
                            .foregroundStyle(Theme.Colors.secondaryText)
                    }
                    Button("Clear cache") {
                        showClearAlert = true
                    }
                    .foregroundStyle(Theme.Colors.accent)
                }

                Section("About") {
                    NavigationLink("Privacy") {
                        PrivacyView()
                    }
                    NavigationLink("About GlowLab") {
                        AboutView()
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear {
                storageBytes = cacheManager.usedStorageBytes()
            }
            .alert("Clear cache?", isPresented: $showClearAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear", role: .destructive) {
                    try? cacheManager.clearExports()
                    storageBytes = cacheManager.usedStorageBytes()
                    clearDone = true
                }
            } message: {
                Text("This will remove all exported images from the app. Your Photos library is not affected.")
            }
        }
    }

    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                Text("GlowLab processes your photos only on your device. We do not upload or store your images on any server. Photos library access is used only to let you pick and save images. You can revoke access in Settings at any time.")
                    .font(.body)
                    .foregroundStyle(Theme.Colors.primaryText)
            }
            .padding(Theme.Spacing.lg)
        }
        .navigationTitle("Privacy")
    }
}

struct AboutView: View {
    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(Theme.Colors.accent)
            Text("GlowLab")
                .font(.title)
                .fontWeight(.bold)
            Text("Premium glow edits in seconds.")
                .font(.subheadline)
                .foregroundStyle(Theme.Colors.secondaryText)
            Text("Version 1.0")
                .font(.caption)
                .foregroundStyle(Theme.Colors.secondaryText)
            Spacer()
        }
        .padding(Theme.Spacing.xl)
        .frame(maxWidth: .infinity)
        .navigationTitle("About")
    }
}

#Preview("Settings") {
    SettingsView(settings: SettingsStore(), cacheManager: CacheManager())
}
