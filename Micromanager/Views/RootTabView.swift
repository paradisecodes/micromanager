import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            Tab("Capture", systemImage: "clock") {
                CaptureView()
            }
            Tab("Check-In", systemImage: "face.smiling") {
                CheckInView()
            }
            Tab("Categories", systemImage: "square.grid.2x2") {
                CategoriesView()
            }
            Tab("Report", systemImage: "chart.bar") {
                ReportView()
            }
        }
    }
}

#Preview {
    RootTabView()
        .environment(AuditStore())
}
