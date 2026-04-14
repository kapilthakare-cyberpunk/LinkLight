import SwiftUI

struct StatusPopoverView: View {
    @ObservedObject var monitor: ReachabilityMonitor

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: monitor.status.symbolName)
                    .foregroundStyle(monitor.status.color)
                    .font(.system(size: 18, weight: .semibold))
                VStack(alignment: .leading, spacing: 2) {
                    Text(monitor.status.rawValue)
                        .font(.headline)
                    Text(monitor.snapshot.endpoint)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            metricRow("Network", monitor.snapshot.networkAvailable ? "Available" : "Unavailable")
            metricRow("DNS", monitor.snapshot.dnsResolved ? "Resolved" : "Unknown/Unavailable")
            metricRow("Latency", formattedLatency(monitor.latency))
            metricRow("Packet loss", formattedPacketLoss(monitor.packetLoss))
            metricRow("Last check", formattedDate(monitor.lastCheckedAt))

            Divider()

            HStack {
                Button("Refresh") {
                    monitor.refresh()
                }
                Spacer()
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .padding(14)
        .frame(width: 280)
    }

    private func metricRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }

    private func formattedLatency(_ latency: TimeInterval?) -> String {
        guard let latency else { return "—" }
        return "\(Int(latency * 1000)) ms"
    }

    private func formattedPacketLoss(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }

    private func formattedDate(_ date: Date?) -> String {
        guard let date else { return "Never" }
        return date.formatted(date: .omitted, time: .standard)
    }
}
