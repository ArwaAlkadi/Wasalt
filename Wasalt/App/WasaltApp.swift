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


// تحويل اللغة
extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
