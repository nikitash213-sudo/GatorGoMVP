import SwiftUI

struct ResourceDetailView: View {
    let resource: ResourceItem
    @Environment(\.openURL) private var openURL

    var body: some View {
        List {
            Section {
                Label(resource.category.uppercased(), systemImage: "bookmark.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(GatorGoTheme.purple)
            }

            Section {
                Text(resource.summary)
                    .foregroundStyle(GatorGoTheme.ink)
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
        .scrollContentBackground(.hidden)
        .background(GatorGoTheme.canvas)
        .tint(GatorGoTheme.purple)
        .navigationTitle(resource.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}
