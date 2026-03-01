import SwiftUI
import Sparkle

@main
struct App: App {
    @StateObject private var updaterController = UpdaterController()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(after: .appInfo) {
                Button(
                    NSLocalizedString(
                        "Check for Updates...",
                        comment: "Menu item to check for app updates"
                    ),
//                    systemImage: "square.and.arrow.down.badge.checkmark"
                    systemImage: "arrow.triangle.2.circlepath"
                ) {
                    updaterController.checkForUpdates()
                }
                .keyboardShortcut("u", modifiers: [.command])
                .disabled(!updaterController.canCheckForUpdates)
            }
        }
    }
}
