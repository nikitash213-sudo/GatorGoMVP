import SwiftUI

struct ExploreView: View {
    @StateObject private var model = ExploreViewModel()

    var body: some View {
        List {
            Section {
                CampusHeader(
                    eyebrow: "San Francisco State",
                    title: "Explore campus",
                    subtitle: "Discover landmarks and collect the places you visit.",
                    systemImage: "map.fill"
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section {
                GoogleMapView(landmarks: model.landmarks)
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            Section("Landmarks") {
                ForEach(model.landmarks) { landmark in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(landmark.name)
                                    .font(.headline)
                                    .foregroundStyle(GatorGoTheme.ink)
                                Text(landmark.description)
                                    .font(.subheadline)
                                    .foregroundStyle(GatorGoTheme.muted)
                            }
                            Spacer()
                            if model.claimedIDs.contains(landmark.id) {
                                Label("Claimed", systemImage: "checkmark.seal.fill")
                                    .labelStyle(.iconOnly)
                                    .foregroundStyle(GatorGoTheme.purple)
                            }
                        }

                        if !model.claimedIDs.contains(landmark.id) {
                            Button("Claim when I’m here") {
                                Task { await model.claim(landmark) }
                            }
                            .fontWeight(.semibold)
                            .tint(GatorGoTheme.purple)
                            .disabled(model.isLoading)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            if !model.claims.isEmpty {
                Section("Collection") {
                    ForEach(model.claims) { claim in
                        LabeledContent(claim.landmarkName) {
                            Text(claim.claimedAt?.formatted(date: .abbreviated, time: .shortened) ?? "Claimed")
                        }
                    }
                }
            }

            Section("Privacy") {
                Text("Location is requested only when you plan from your current location or tap Claim. Landmark verification stores the claim and coarse verification metadata, not a continuous location trail.")
                    .font(.footnote)
            }
        }
        .scrollContentBackground(.hidden)
        .background(GatorGoTheme.canvas)
        .tint(GatorGoTheme.purple)
        .navigationTitle("Explore")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable { await model.load() }
        .task { await model.load() }
        .alert("Landmark", isPresented: .constant(model.successMessage != nil)) {
            Button("OK") { model.successMessage = nil }
        } message: {
            Text(model.successMessage ?? "")
        }
        .alert("Could not complete action", isPresented: .constant(model.errorMessage != nil)) {
            Button("OK") { model.errorMessage = nil }
        } message: {
            Text(model.errorMessage ?? "")
        }
    }
}
