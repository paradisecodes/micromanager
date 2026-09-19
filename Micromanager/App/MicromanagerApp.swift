import SwiftUI

@main
struct MicromanagerApp: App {
    @State private var store = Self.makeStore()

    private static func makeStore() -> AuditStore {
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-seedPreviewAudit") {
            return .preview()
        }
        #endif
        return AuditStore()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if store.currentAudit == nil {
                    OnboardingView()
                } else {
                    RootTabView()
                }
            }
            .environment(store)
        }
    }
}
