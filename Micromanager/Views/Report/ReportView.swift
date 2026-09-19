import SwiftUI

/// Placeholder for the post-audit AI-generated analysis. The AI engine
/// itself is an open question in the PRD (cost vs. accuracy tradeoff) —
/// this view just needs a place to render the eventual output.
struct ReportView: View {
    @Environment(AuditStore.self) private var store

    var body: some View {
        NavigationStack {
            Group {
                if store.currentAudit == nil {
                    ContentUnavailableView(
                        "No Audit Yet",
                        systemImage: "chart.bar.doc.horizontal",
                        description: Text("Start a two-week audit to see your report here.")
                    )
                } else {
                    ContentUnavailableView(
                        "Audit In Progress",
                        systemImage: "hourglass",
                        description: Text("Your report will be available once the two-week capture period ends.")
                    )
                }
            }
            .navigationTitle("Report")
        }
    }
}

#Preview {
    ReportView()
        .environment(AuditStore())
}
