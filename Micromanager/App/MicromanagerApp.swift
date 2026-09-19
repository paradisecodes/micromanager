import SwiftUI

@main
struct MicromanagerApp: App {
    @State private var store = AuditStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environment(store)
        }
    }
}
