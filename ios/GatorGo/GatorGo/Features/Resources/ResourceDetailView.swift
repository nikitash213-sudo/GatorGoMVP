import SwiftUI

struct ResourceDetailView: View {
    let resource: ResourceItem
    @Environment(\.openURL) private var openURL

    var body: some View {
        List {
            Section {
                Text(resource.summary)
            }

            Section("Eligibility") {
                Text(resource.eligibility)
            }

            Section("Cost") {
                Text(resource.costLabel)
            }

            Section("Trust") {
                LabeledContent("Source", value: resource.sourceName)
                LabeledContent("Freshness", value: resource.freshnessLabel)
                if resource.isDemo == true {
                    Label("Prototype/demo record. Replace with verified production data.", systemImage: "exclamationmark.triangle")
                }
                if let url = URL(string: resource.sourceURL) {
                    Button("Verify at source") { openURL(url) }
                }
            }
        }
        .navigationTitle(resource.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
