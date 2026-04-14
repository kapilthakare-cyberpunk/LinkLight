import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    let onSave: () -> Void

    var body: some View {
        Form {
            Section("Endpoint") {
                TextField("https://1.1.1.1", text: $viewModel.endpointURLString)
                    .textFieldStyle(.roundedBorder)
                Text("Used for active reachability checks.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Timing") {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Check interval")
                        Spacer()
                        Text("\(Int(viewModel.checkInterval))s")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $viewModel.checkInterval, in: 5...60, step: 5)
                }

                VStack(alignment: .leading) {
                    HStack {
                        Text("Request timeout")
                        Spacer()
                        Text("\(Int(viewModel.requestTimeout))s")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $viewModel.requestTimeout, in: 1...10, step: 1)
                }

                VStack(alignment: .leading) {
                    HStack {
                        Text("Flaky latency threshold")
                        Spacer()
                        Text("\(Int(viewModel.flakinessLatencyThreshold * 1000)) ms")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $viewModel.flakinessLatencyThreshold, in: 0.1...2.0, step: 0.1)
                }
            }

            Section("History") {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Sample history size")
                        Spacer()
                        Text("\(Int(viewModel.historyLimit))")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $viewModel.historyLimit, in: 1...10, step: 1)
                }
            }

            HStack {
                Button("Reset Defaults") {
                    viewModel.reset()
                }
                Spacer()
                Button("Save") {
                    viewModel.save()
                    onSave()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.top, 8)
        }
        .padding(16)
        .frame(width: 420)
    }
}
