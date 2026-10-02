import SwiftUI

struct AskNavigatorView: View {
    @StateObject private var model = AskNavigatorViewModel()

    var body: some View {
        List {
            Section {
                CampusHeader(
                    eyebrow: "San Francisco State",
                    title: "Ask GatorGo",
                    subtitle: "Get answers grounded in the campus resource catalog.",
                    systemImage: "sparkles"
                )
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }

            Section {
                TextField("What do you need?", text: $model.question, axis: .vertical)
                    .lineLimit(3...6)
                Button {
                    Task { await model.ask() }
                } label: {
                    HStack {
                        if model.isLoading { ProgressView() }
                        Text(model.isLoading ? "Checking records…" : "Ask GatorGo")
                    }
                }
                .disabled(model.isLoading || model.question.trimmingCharacters(in: .whitespacesAndNewlines).count < 3)
            } footer: {
                Text("Answers are limited to records retrieved from the app database. Open the source before acting on time-sensitive details.")
            }

            if let response = model.response {
                Section("Answer") {
                    Text(response.answer)
                }

                if !response.resources.isEmpty {
                    Section("Referenced records") {
                        ForEach(response.resources) { resource in
                            NavigationLink {
                                ResourceDetailView(resource: resource)
                            } label: {
                                ResourceCard(resource: resource)
                            }
                        }
                    }
                }

                if !response.caveats.isEmpty {
                    Section("Caveats") {
                        ForEach(response.caveats, id: \.self) { Text($0) }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(GatorGoTheme.canvas)
        .tint(GatorGoTheme.purple)
        .navigationTitle("Ask GatorGo")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Could not answer", isPresented: .constant(model.errorMessage != nil)) {
            Button("OK") { model.errorMessage = nil }
        } message: {
            Text(model.errorMessage ?? "")
        }
    }
}
