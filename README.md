# GlowLab

A premium “one-tap glow” photo editor for iOS: studio-grade glow filters and light overlays with a minimal, Apple-like UX.

## Requirements

- Xcode 15+
- iOS 17+ (SwiftData, Swift 5.9)
- iPhone and iPad (adaptive layout)

## Setup

1. Open `DF864w.xcodeproj` in Xcode.
2. Select the **DF864w** scheme and a simulator or device (iOS 17+).
3. Build and run (⌘R).

### Photos permission

To allow picking and saving photos, add the following to your target’s **Info** (or set **Info.plist File** to `DF864w/Info.plist` in Build Settings):

- **NSPhotoLibraryUsageDescription**: “GlowLab needs access to your photos to let you pick images to edit. All editing happens on your device; nothing is uploaded.”
- **NSPhotoLibraryAddUsageDescription**: “GlowLab saves your edited photos to your library when you choose Save to Photos.”

If you use a custom Info.plist, merge these keys into it. The repo includes `DF864w/Info.plist` with these entries; link it in the target’s **Build Settings → Info.plist File** if you rely on it.

## How rendering works

- **Core Image pipeline**: Each glow style uses a CIImage pipeline: bloom (CIBloom), tone/contrast (CIColorMatrix, CIExposureAdjust), warmth (custom matrix), optional style overlay (light leak or reflection), vignette (CIVignette), and grain (CIRandomGenerator + blend).
- **Non-destructive**: Only parameters are stored; the original image is never overwritten.
- **Performance**: Preview uses a downscaled render (max 800–1200 px in the long edge, depending on “Performance mode” in Settings). Export always uses full resolution (or the chosen export size: Original / 2048 / 1080).
- **Throttling**: Slider changes trigger a debounced preview render (~60 ms) to avoid overload on large images.

## Test instructions

### Unit tests

- In Xcode: **Product → Test** (⌘U), or run the **DF864wTests** scheme.
- Covers:
  - **GlowParameters**: Encode/decode, default-per-style, equality.
  - **PresetStore**: CRUD with in-memory SwiftData container.
  - **GlowRenderer**: Preview and full-resolution output for sample CIImages; different parameters produce different results.
  - **Export pipeline**: Export produces a file, correct format/size, and progress callback.

### UI tests

- Run the **DF864wUITests** scheme (⌘U with that scheme, or **Product → Test** when UITests are enabled).
- Scenarios:
  - Onboarding → “Import Photo” visible.
  - Opening Settings and Gallery.
  - Opening Presets (after skipping onboarding if needed).

## QA checklist

- [ ] **Build & run**: App builds and launches without crashes.
- [ ] **Onboarding**: All three screens show; “Get Started” → “Continue” → “Start Editing” completes and shows home.
- [ ] **Import**: “Import Photo” opens PHPicker; selecting one image loads it and opens the editor.
- [ ] **Editor**: Style carousel shows all 8 styles; selecting a style updates the preview. Sliders (Intensity, Bloom, Warmth, etc.) update the image; Undo/Redo work. Compare (long-press or Compare button) shows original; release shows edited.
- [ ] **Export**: Export shows progress, then share sheet. “Save to Photos” works if permission granted. Export appears in Gallery.
- [ ] **Presets**: Save current settings as a preset (name required). Presets list shows built-in and user presets; Apply applies parameters; Rename/Delete work.
- [ ] **Gallery**: List of exports; tap opens detail; Share and Delete work.
- [ ] **Settings**: Theme (Light/Dark/System), Haptics, default format/size, JPEG quality, Performance mode, Storage (size + Clear cache), About and Privacy open correctly.
- [ ] **Layouts**: iPhone SE (small), iPhone 15 Pro Max (large), iPad Air 11″ — no clipped text, overlapping elements, or broken spacing; scroll where needed.
- [ ] **Accessibility**: Dynamic Type, VoiceOver (labels/hints), Reduce Motion respected; sufficient contrast.
- [ ] **Offline**: All features work with no network.

## Project structure

- **App**: `DF864wApp.swift`, `ContentView.swift`
- **DesignSystem**: Theme, PrimaryButton, GlassPanel, EmptyStateView, LabeledSlider
- **Models**: GlowStyle, GlowParameters, Preset (SwiftData), ExportedItem (SwiftData)
- **Persistence**: GlowLabSchema (SwiftData schema/config)
- **Services**: GlowRenderer, PhotoImporter, PhotoExporter, PresetStore, CacheManager, SettingsStore
- **Features**: Onboarding, Import, Editor, Presets, Gallery, Settings, Root (navigation)

## Assets

- **Colors**: PrimaryBackground, SecondaryBackground, CardSurface, PrimaryText, SecondaryText, Accent, AccentMuted, Divider (in Assets.xcassets).
- **Light leak overlays**: Optional images `LightLeak1`…`LightLeak8` in the asset catalog improve warm/golden-hour styles; the renderer works without them using programmatic overlays where applicable.
- **App icon**: Use the existing AppIcon placeholder or replace with your own (e.g. SF Symbol–based icon).

## License

Proprietary / as per your project.
