import SwiftUI

enum GatorGoTheme {
    static let purple = Color(red: 0.29, green: 0.09, blue: 0.42)
    static let deepPurple = Color(red: 0.19, green: 0.04, blue: 0.29)
    static let gold = Color(red: 0.98, green: 0.72, blue: 0.16)
    static let canvas = Color(red: 0.97, green: 0.95, blue: 0.98)
    static let ink = Color(red: 0.16, green: 0.12, blue: 0.19)
    static let muted = Color(red: 0.43, green: 0.39, blue: 0.46)
}

struct CampusHeader: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 7) {
                Text(eyebrow.uppercased())
                    .font(.caption.weight(.bold))
                    .foregroundStyle(GatorGoTheme.gold)

                Text(title)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.82))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Image(systemName: systemImage)
                .font(.system(size: 23, weight: .semibold))
                .foregroundStyle(GatorGoTheme.deepPurple)
                .frame(width: 48, height: 48)
                .background(GatorGoTheme.gold, in: RoundedRectangle(cornerRadius: 12))
                .accessibilityHidden(true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            LinearGradient(
                colors: [GatorGoTheme.purple, GatorGoTheme.deepPurple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(GatorGoTheme.gold)
                .frame(width: 4)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}