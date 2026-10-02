import SwiftUI

struct ResourceCard: View {
    let resource: ResourceItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(resource.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(GatorGoTheme.ink)
                Spacer()
                Text(resource.category.uppercased())
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(GatorGoTheme.purple)
            }

            Text(resource.summary)
                .font(.subheadline)
                .foregroundStyle(GatorGoTheme.ink)

            HStack {
                Label(resource.costLabel, systemImage: "dollarsign.circle")
                Spacer()
                Text(resource.freshnessLabel)
            }
            .font(.caption)
            .foregroundStyle(GatorGoTheme.muted)

            if resource.isDemo == true {
                Label("Demo data — verify before relying on it", systemImage: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundStyle(GatorGoTheme.muted)
            }
        }
        .padding(.vertical, 4)
    }
}
