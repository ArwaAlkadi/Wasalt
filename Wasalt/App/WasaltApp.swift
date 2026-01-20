import SwiftUI
import Foundation

@main
struct WasaltApp: App {
    var body: some Scene {
        WindowGroup {
            RootAppView()
        }
    }
}

// MARK: - Localization Helper
/// Language localization
extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
