//
// ALLMYSCREENS — fork of MacsyZones (GPL-3.0)
//

import SwiftUI
import AppKit

enum PortraitPreset: String, CaseIterable {
    case halves
    case thirds

    var layoutName: String {
        switch self {
        case .halves: return "Portrait Halves"
        case .thirds: return "Portrait Thirds"
        }
    }

    var label: String {
        switch self {
        case .halves: return "Halves"
        case .thirds: return "Thirds"
        }
    }
}

enum MonitorTarget: String, CaseIterable {
    case left
    case right
    case both

    var label: String {
        switch self {
        case .left: return "Left"
        case .right: return "Right"
        case .both: return "Both"
        }
    }
}

struct QuickLayoutStateData: Codable {
    var hasCompletedPortraitSetup: Bool?
}

class QuickLayoutState: UserData, ObservableObject {
    @Published var hasCompletedPortraitSetup: Bool = false

    init() {
        super.init(name: "QuickLayoutState", data: "{}", fileName: "QuickLayoutState.json")
    }

    override func load() {
        super.load()
        guard let jsonData = data.data(using: .utf8) else { return }
        if let state = try? JSONDecoder().decode(QuickLayoutStateData.self, from: jsonData) {
            hasCompletedPortraitSetup = state.hasCompletedPortraitSetup ?? false
        }
    }

    override func save() {
        let state = QuickLayoutStateData(hasCompletedPortraitSetup: hasCompletedPortraitSetup)
        if let jsonData = try? JSONEncoder().encode(state),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            data = jsonString
            super.save()
        }
    }
}

let quickLayoutState = QuickLayoutState()

enum QuickLayoutPresets {
    static func isPortrait(_ screen: NSScreen) -> Bool {
        screen.frame.height > screen.frame.width
    }

    static func sortedScreensByX() -> [NSScreen] {
        NSScreen.screens.sorted { $0.frame.minX < $1.frame.minX }
    }

    static func leftScreen() -> NSScreen? {
        sortedScreensByX().first
    }

    static func rightScreen() -> NSScreen? {
        let screens = sortedScreensByX()
        return screens.count > 1 ? screens.last : nil
    }

    static func portraitExternalScreens() -> [NSScreen] {
        sortedScreensByX().filter { isPortrait($0) }
    }

    static func sectionConfigs(for preset: PortraitPreset) -> [SectionConfig] {
        switch preset {
        case .halves:
            return [
                .init(number: 1, widthPercentage: 1.0, heightPercentage: 0.5, xPercentage: 0.0, yPercentage: 0.0, name: "Bottom Half"),
                .init(number: 2, widthPercentage: 1.0, heightPercentage: 0.5, xPercentage: 0.0, yPercentage: 0.5, name: "Top Half"),
            ]
        case .thirds:
            let third = 1.0 / 3.0
            return [
                .init(number: 1, widthPercentage: 1.0, heightPercentage: third, xPercentage: 0.0, yPercentage: 0.0, name: "Bottom Third"),
                .init(number: 2, widthPercentage: 1.0, heightPercentage: third, xPercentage: 0.0, yPercentage: third, name: "Middle Third"),
                .init(number: 3, widthPercentage: 1.0, heightPercentage: third, xPercentage: 0.0, yPercentage: 2.0 * third, name: "Top Third"),
            ]
        }
    }

    static func ensurePresetLayoutsExist() {
        for preset in PortraitPreset.allCases {
            userLayouts.upsertZoneLayout(name: preset.layoutName, sectionConfigs: sectionConfigs(for: preset))
        }
    }

    static func assignLayout(_ layoutName: String, to screen: NSScreen) {
        guard let screenNumber = getScreenNumber(screen: screen),
              let spaceNumber = SpaceLayoutPreferences.getCurrentSpaceNumber() else { return }
        spaceLayoutPreferences.set(screenNumber: screenNumber, spaceNumber: spaceNumber, layoutName: layoutName)
    }

    static func apply(preset: PortraitPreset, to target: MonitorTarget) {
        ensurePresetLayoutsExist()
        let layoutName = preset.layoutName

        switch target {
        case .left:
            if let screen = leftScreen() {
                assignLayout(layoutName, to: screen)
            }
        case .right:
            if let screen = rightScreen() {
                assignLayout(layoutName, to: screen)
            }
        case .both:
            for screen in sortedScreensByX() {
                assignLayout(layoutName, to: screen)
            }
        }

        if let focused = getFocusedScreen(),
           let screenNumber = getScreenNumber(screen: focused),
           let spaceNumber = SpaceLayoutPreferences.getCurrentSpaceNumber(),
           let assigned = spaceLayoutPreferences.get(screenNumber: screenNumber, spaceNumber: spaceNumber) {
            userLayouts.setCurrentLayout(name: assigned)
            spaceLayoutPreferences.switchToCurrent()
        }

        userLayouts.save()
        spaceLayoutPreferences.save()
    }

    static func shouldOfferPortraitSetup() -> Bool {
        !quickLayoutState.hasCompletedPortraitSetup && portraitExternalScreens().count >= 2
    }

    static func completePortraitSetup(preset: PortraitPreset) {
        apply(preset: preset, to: .both)
        quickLayoutState.hasCompletedPortraitSetup = true
        quickLayoutState.save()
    }
}

struct QuickLayoutPanel: View {
    @State private var selectedPreset: PortraitPreset = .halves
    @State private var selectedTarget: MonitorTarget = .both

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick Layouts").font(.subheadline)

            HStack(spacing: 6) {
                Text("Layout:").font(.caption).foregroundColor(.secondary)
                Picker("Layout", selection: $selectedPreset) {
                    ForEach(PortraitPreset.allCases, id: \.self) { preset in
                        Text(preset.label).tag(preset)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            HStack(spacing: 6) {
                Text("Apply to:").font(.caption).foregroundColor(.secondary)
                Picker("Monitor", selection: $selectedTarget) {
                    ForEach(MonitorTarget.allCases, id: \.self) { target in
                        Text(target.label).tag(target)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            Button("Apply Now") {
                QuickLayoutPresets.apply(preset: selectedPreset, to: selectedTarget)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

struct PortraitSetupView: View {
    @State private var selectedPreset: PortraitPreset = .halves
    var onComplete: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Image(systemName: "rectangle.split.3x1")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)

            Text("Portrait Monitor Setup")
                .font(.title2)

            Text("Two portrait monitors detected. Choose a default zone layout — each screen gets stacked containers so apps fill a zone, not the whole display.")
                .font(.system(size: 13))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Picker("Layout", selection: $selectedPreset) {
                ForEach(PortraitPreset.allCases, id: \.self) { preset in
                    Text(preset.label).tag(preset)
                }
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 280)

            Button("Apply to Both Monitors") {
                QuickLayoutPresets.completePortraitSetup(preset: selectedPreset)
                onComplete()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)

            Button("Skip for now") {
                quickLayoutState.hasCompletedPortraitSetup = true
                quickLayoutState.save()
                onComplete()
            }
            .buttonStyle(.plain)
            .foregroundColor(.secondary)
        }
        .padding(28)
        .frame(width: 400)
    }
}

private var portraitSetupWindow: NSWindow?

func showPortraitSetupIfNeeded() {
    guard QuickLayoutPresets.shouldOfferPortraitSetup() else { return }

    let window = NSWindow()
    window.title = "ALLMYSCREENS Setup"
    window.styleMask = [.titled, .closable, .fullSizeContentView]
    window.titlebarAppearsTransparent = true
    window.isReleasedWhenClosed = false
    window.level = .floating
    window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

    let view = PortraitSetupView {
        window.close()
        portraitSetupWindow = nil
    }
    window.contentViewController = NSHostingController(rootView: view)
    window.center()
    portraitSetupWindow = window

    NSApp.activate(ignoringOtherApps: true)
    window.makeKeyAndOrderFront(nil)
}
