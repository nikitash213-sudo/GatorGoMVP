import SwiftUI

struct ResourceCard: View {
    let resource: ResourceItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(resource.title)
                    .font(.headline)
                Spacer()
                Text(resource.category.uppercased())
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Text(resource.summary)
                .font(.subheadline)

            HStack {
                Label(resource.costLabel, systemImage: "dollarsign.circle")
                Spacer()
                Text(resource.freshnessLabel)
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if resource.isDemo == true {
                Label("Demo data — verify before relying on it", systemImage: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
