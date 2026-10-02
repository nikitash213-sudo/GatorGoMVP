import SwiftUI

struct TripPlannerView: View {
    @StateObject private var model = TripPlannerViewModel()

    var body: some View {
        Form {
            Section("Trip") {
                Picker("Destination", selection: $model.selectedLandmarkID) {
                    ForEach(model.landmarks) { landmark in
                        Text(landmark.name)
                            .tag(Optional(landmark.id))
                    }
                }

                Picker("Preference", selection: $model.preference) {
                    ForEach(PlanTripRequest.Preference.allCases) { preference in
                        Text(preference.title)
                            .tag(preference)
                    }
                }

                Toggle(
                    "Arrive by a specific time",
                    isOn: $model.includeArrivalTime
                )

                if model.includeArrivalTime {
                    DatePicker(
                        "Arrival",
                        selection: $model.arrivalTime,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
            }

            Section {
                TextField(
                    "Budget note, e.g. lowest cost",
                    text: $model.budgetNote
                )

                TextField(
                    "Accessibility need you want considered",
                    text: $model.accessibilityNote,
                    axis: .vertical
                )
                .lineLimit(2...4)
            } header: {
                Text("Optional constraints")
            } footer: {
                Text(
                    "GatorGo only uses constraints you explicitly enter. It does not infer sensitive traits."
                )
            }

            Section {
                Button {
                    Task {
                        await model.plan()
                    }
                } label: {
                    HStack {
                        if model.isLoading {
                            ProgressView()
                        }

                        Text(
                            model.isLoading
                                ? "Planning…"
                                : "Plan from my location"
                        )
                    }
                }
                .disabled(
                    model.isLoading ||
                    model.selectedLandmark == nil
                )
            }

            if let result = model.result {
                TripResultView(
                    result: result,
                    destination: model.selectedLandmark
                )
            }
        }
        .navigationTitle("Plan a Trip")
        .task {
            await model.load()
        }
        .alert(
            "Could not plan trip",
            isPresented: .constant(model.errorMessage != nil)
        ) {
            Button("OK") {
                model.errorMessage = nil
            }
        } message: {
            Text(model.errorMessage ?? "")
        }
    }
}

private struct TripResultView: View {
    let result: PlanTripResponse
    let destination: Landmark?

    private var recommended: TransitRoute? {
        result.routes.first {
            $0.id == result.recommendedRouteId
        } ?? result.routes.first
    }

    var body: some View {
        Section("Grounded recommendation") {
            Text(result.explanation)

            if let destination, let recommended {
                GoogleMapView(
                    landmarks: [destination],
                    routePolyline: recommended.encodedPolyline,
                    focusedCoordinate: destination.location
                )
                .frame(height: 220)
                .clipShape(
                    RoundedRectangle(cornerRadius: 12)
                )
            }

            ForEach(result.routes) { route in
                VStack(
                    alignment: .leading,
                    spacing: 6
                ) {
                    HStack {
                        Text(
                            route.id == result.recommendedRouteId
                                ? "Suggested route"
                                : "Alternate"
                        )
                        .font(.headline)

                        Spacer()

                        Text(route.durationText)
                            .fontWeight(.semibold)
                    }

                    Text(route.distanceText)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ForEach(
                        route.transitSteps,
                        id: \.self
                    ) { step in
                        Label(
                            step,
                            systemImage: "tram.fill"
                        )
                        .font(.subheadline)
                    }
                }
            }
        }

        if !result.resources.isEmpty {
            Section("Near your destination") {
                ForEach(result.resources) { resource in
                    ResourceCard(resource: resource)
                }
            }
        }

        if !result.caveats.isEmpty {
            Section("Check before you go") {
                ForEach(
                    result.caveats,
                    id: \.self
                ) { caveat in
                    Text(caveat)
                }
            }
        }
    }
}
