import SwiftUI

struct RootTabView: View {
    @State private var selection = Self.initialTab()

    private static func initialTab() -> Int {
        #if DEBUG
        if let index = ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix("-startTab=") })?.split(separator: "=").last {
            return Int(index) ?? 0
        }
        #endif
        return 0
    }

    var body: some View {
        TabView(selection: $selection) {
            Tab("Today", systemImage: "clock", value: 0) {
                TodayView()
            }
            Tab("Days", systemImage: "calendar", value: 1) {
                DaysView()
            }
            Tab("Categories", systemImage: "square.grid.2x2", value: 2) {
                CategoriesView()
            }
            Tab("Report", systemImage: "chart.bar", value: 3) {
                ReportOverviewView()
            }
        }
        .tint(Color.dsIndigo)
    }
}

#Preview {
    RootTabView()
        .environment(AuditStore.preview())
}
