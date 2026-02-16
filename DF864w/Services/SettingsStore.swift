//
//  SettingsStore.swift
//  DF864w
//

import Foundation
import SwiftUI

enum AppTheme: String, CaseIterable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
}

protocol SettingsStoring {
    var hasCompletedOnboarding: Bool { get set }
    var appTheme: AppTheme { get set }
    var hapticsEnabled: Bool { get set }
    var defaultExportFormat: ExportFormat { get set }
    var defaultExportResolution: ExportResolution { get set }
    var performanceMode: Bool { get set }
    var jpegQuality: Double { get set }
}

@Observable
final class SettingsStore: SettingsStoring {
    @ObservationIgnored @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @ObservationIgnored @AppStorage("appTheme") private var appThemeRaw: String = AppTheme.system.rawValue
    @ObservationIgnored @AppStorage("hapticsEnabled") var hapticsEnabled: Bool = true
    @ObservationIgnored @AppStorage("defaultExportFormat") private var defaultExportFormatRaw: String = ExportFormat.jpeg.rawValue
    @ObservationIgnored @AppStorage("defaultExportResolution") private var defaultExportResolutionRaw: String = ExportResolution.px2048.rawValue
    @ObservationIgnored @AppStorage("performanceMode") var performanceMode: Bool = false
    @ObservationIgnored @AppStorage("jpegQuality") var jpegQuality: Double = 0.92

    var appTheme: AppTheme {
        get { AppTheme(rawValue: appThemeRaw) ?? .system }
        set { appThemeRaw = newValue.rawValue }
    }

    var defaultExportFormat: ExportFormat {
        get { ExportFormat(rawValue: defaultExportFormatRaw) ?? .jpeg }
        set { defaultExportFormatRaw = newValue.rawValue }
    }

    var defaultExportResolution: ExportResolution {
        get { ExportResolution(rawValue: defaultExportResolutionRaw) ?? .px2048 }
        set { defaultExportResolutionRaw = newValue.rawValue }
    }
}
